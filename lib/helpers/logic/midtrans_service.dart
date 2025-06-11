import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MidTransService {
  // NOTE: Singleton handler
  static final MidTransService _instance = MidTransService._();
  static MidTransService get instance => _instance;
  MidTransService._();

  // NOTE: Variable mid trans
  late String serverKey;
  late String baseUrl;
  bool isInitialized = false;

  // NOTE: buat inisialisai class
  static Future<void> initialize() async {
    try {
      await dotenv.load();
      
      instance.serverKey = dotenv.env['MIDTRANS_SERVER_KEY'] ?? '';
      final isProduction = dotenv.env['MIDTRANS_IS_PRODUCTION']?.toLowerCase() == 'true';
      
      if (instance.serverKey.isEmpty) {
        throw Exception('MIDTRANS_SERVER_KEY not found in .env file');
      }
      
      instance.baseUrl = isProduction 
          ? 'https://api.midtrans.com/v2'
          : 'https://api.sandbox.midtrans.com/v2';
      
      instance.isInitialized = true;
      
      if (kDebugMode) {
        print('MidTrans initialized successfully');
        print('Environment: ${isProduction ? 'Production' : 'Sandbox'}');
      }
    } catch (e) {
      throw Exception('Failed to initialize MidTrans: $e');
    }
  }

  // NOTE: buat generate id random
  String _generatePaymentId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'PAYMENT-$timestamp';
  }

  // NOTE: Buat bikin qris
  Future<Map<String, dynamic>> createQrisPayment({
    required double amount,
    required String customerName,
    required String customerEmail,
    int expirySeconds = 60,
  }) async {
    if (!isInitialized) {
      throw Exception('MidTransService not initialized');
    }

    final orderId = _generatePaymentId();
    
    final requestBody = {
      'payment_type': 'qris',
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': amount.toInt(),
      },
      'customer_details': {
        'first_name': customerName,
        'email': customerEmail,
      },
      'qris': {
        'acquirer': 'gopay',
      },
      'custom_expiry': {
        'order_time': '${DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19)} +0700',
        'expiry_duration': expirySeconds,
        'unit': 'second',
      },
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/charge'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$serverKey:'))}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          final qrCodeUrl = responseData['actions']?.firstWhere((action) => action['name'] == 'generate-qr-code')['url'];
          print("\x1B[96m===================================SIMULATING MIDTRANS PAYMENT===================================");
          print("Please head to https://simulator.sandbox.midtrans.com/v2/qris/ for QRIS scanning payment simulation.");
          print("Input this URL: $qrCodeUrl");
          print("=================================================================================================\x1B[0m");
        }
        return {
          'success': true,
          'order_id': orderId,
          'transaction_id': responseData['transaction_id'],
          'qr_string': responseData['qr_string'],
          'transaction_status': responseData['transaction_status'],
          'response': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error_messages'] ?? ['Payment creation failed'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': ['Network error: $e'],
      };
    }
  }


  // NOTE: buat cek status
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    if (!isInitialized) {
      throw Exception('MidTransService not initialized');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$transactionId/status'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$serverKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'transaction_status': responseData['transaction_status'],
          'payment_type': responseData['payment_type'],
          'transaction_time': responseData['transaction_time'],
          'response': responseData,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to check payment status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}