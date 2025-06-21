import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmb_skripsi/helpers/logic/midtrans_service.dart';
import 'package:lmb_skripsi/helpers/logic/remote_config_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LmbPaymentQr extends StatefulWidget {
  final double amount;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;

  const LmbPaymentQr({
    super.key,
    required this.amount,
    this.onPaymentSuccess,
    this.onPaymentFailed
  });

  @override
  State<LmbPaymentQr> createState() => _LmbPaymentQrState();
}

class _LmbPaymentQrState extends State<LmbPaymentQr> {
  Timer? _timer;
  Timer? _statusCheckTimer;
  int _remainingSeconds = 120;
  bool _isLoading = true;
  String? _qrString;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    initializePayment();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> initializePayment() async {
    if (await RemoteConfigService.instance.get<bool>(
      'payment_bypass_config',
      (json) => json as bool
    )) {
      bypassPayment();
    }

    try {
      if (!MidTransService.instance.isInitialized) {
        await MidTransService.initialize();
      }

      final userData = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
      final result = await MidTransService.instance.createQrisPayment(
        amount: widget.amount,
        customerName: userData?.name ?? 'Customer',
        customerEmail: userData?.email ?? 'customer@example.com',
        expirySeconds: _remainingSeconds
      );

      if (result['success']) {
        setState(() {
          _isLoading = false;
          _qrString = result['qr_string'];
          _orderId = result['order_id'];
        });
        startTimer();
        startStatusChecking();
      } else {
        widget.onPaymentFailed?.call();
        if (mounted) {
          Navigator.of(context).pop();
          WindowProvider.toastError(context, "Payment timed out");
        }
      }
    } catch (e) {
      widget.onPaymentFailed?.call();
      if (mounted) {
        Navigator.of(context).pop();
        WindowProvider.toastError(context, "Payment system error", e);
      }
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _statusCheckTimer?.cancel();
        onTimeout();
      }
    });
  }

  void startStatusChecking() {
    if (_orderId == null) return;

    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_orderId != null) {
        final statusResult = await MidTransService.instance.checkPaymentStatus(_orderId!);
        
        if (statusResult['success']) {
          final status = statusResult['transaction_status'];
          
          if (status == 'settlement' || status == 'capture') {
            _timer?.cancel();
            _statusCheckTimer?.cancel();
            onPaymentSuccess();
          } else if (status == 'expire' || status == 'cancel' || status == 'failure') {
            _timer?.cancel();
            _statusCheckTimer?.cancel();
            onPaymentFailed();
          }
        }
      }
    });
  }

  void bypassPayment() {
    if (mounted) {
      WindowProvider.showDialogBox(
        context: context, 
        title: 'Payment Bypass', 
        description: 'The payment system is currently disabled and we allow users to freely add balance without using real money. You can choose wether to proceed payment or cancel it.', 
        primaryText: 'Proceed', 
        onPrimary: onPaymentSuccess,
        secondaryText: 'Cancel', 
        onSecondary: onPaymentFailed
      );
    }
  }

  void onPaymentSuccess() {
    if (mounted) {
      widget.onPaymentSuccess?.call();
      Navigator.of(context).pop();
    }
  }

  void onPaymentFailed() {
    if (mounted) {
      widget.onPaymentFailed?.call();
      Navigator.of(context).pop();
    }
  }

  void onTimeout() {
    if (mounted) {
      widget.onPaymentFailed?.call();
      Navigator.of(context).pop();
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final formatter = NumberFormat('00');

    return '${formatter.format(minutes)}:${formatter.format(remainingSeconds)}';
  }

  @override
  Widget build(BuildContext context) {    
    // NOTE: Loading
    if (_isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_qrString != null) ...[              
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Scan QRIS to pay',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      ValueFormatter.formatPriceIDR(widget.amount),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: LmbColors.brand,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: QrImageView(
                      data: _qrString!,
                      version: QrVersions.auto,
                      size: MediaQuery.of(context).size.width - 64,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 32,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _remainingSeconds <= 10 
                              ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Time remaining: ${formatTime(_remainingSeconds)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _remainingSeconds <= 10 
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: Text(
                          'Please complete your payment within the time limit. Transaction will be automatically cancelled if not completed in time.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  )
                )
              ],
            ]
          ),
        )
      )
    );
  }
}