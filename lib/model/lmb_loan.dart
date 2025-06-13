import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lmb_skripsi/model/lmb_loan_interest.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';

class LmbLoan {
  final String? id;
  final LmbUser loanMaker;
  final double loanAmount;
  final LmbLoanInterest loanInterestPeriod;
  final String bankName;
  final String bankAccountNumber;
  final String reason;
  final int paymentCounter;
  final DateTime? createdAt;

  LmbLoan({
    this.id,
    required this.loanMaker,
    required this.loanAmount,
    required this.loanInterestPeriod,
    required this.bankName,
    required this.bankAccountNumber,
    required this.paymentCounter,
    required this.reason,
    this.createdAt
  });

  Map<String, dynamic> toJson() {
    return {
      'loan_amount': loanAmount,
      'loan_interest_period': loanInterestPeriod.toJson(),
      'bank_name': bankName,
      'bank_account_number': bankAccountNumber,
      'payment_counter': paymentCounter,
      'reason': reason,
      'created_at': DateTime.now(),
    };
  }

  factory LmbLoan.fromJson(Map<String, dynamic> json, LmbUser? userData, {String? id}) {
    final dynamic rawDate = json['created_at'];

    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate().toLocal();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMicrosecondsSinceEpoch(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return LmbLoan(
      id: id,
      loanMaker: userData ?? LmbUser(name: '-', nik: '-', email: '-', createdAt: DateTime.now()),
      loanAmount: (json['loan_amount'] as num).toDouble(),
      loanInterestPeriod: LmbLoanInterest.fromJson(json['loan_interest_period']),
      bankName: json['bank_name'] ?? '',
      bankAccountNumber: json['bank_account_number'] ?? '',
      paymentCounter: json['payment_counter'] ?? 0,
      reason: json['reason'] ?? '',
      createdAt: parsedDate,
    );
  }
}