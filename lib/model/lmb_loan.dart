import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lmb_skripsi/model/lmb_loan_interest.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';

class LmbLoan {
  final LmbUser loanMaker;
  final double loanAmount;
  final LmbLoanInterest loanInterestPeriod;
  final String bankAccountNumber;
  final String reason;
  final DateTime? createdAt;

  LmbLoan({
    required this.loanMaker,
    required this.loanAmount,
    required this.loanInterestPeriod,
    required this.bankAccountNumber,
    required this.reason,
    this.createdAt
  });

  Map<String, dynamic> toJson() {
    return {
      'loanAmount': loanAmount,
      'loanInterestPeriod': loanInterestPeriod.toJson(),
      'bankAccountNumber': bankAccountNumber,
      'reason': reason,
      'createdAt': DateTime.now(),
    };
  }

  factory LmbLoan.fromJson(Map<String, dynamic> json, LmbUser? userData) {
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
      loanMaker: userData ?? LmbUser(name: '-', nik: '-', email: '-', createdAt: DateTime.now()),
      loanAmount: (json['loanAmount'] as num).toDouble(),
      loanInterestPeriod: LmbLoanInterest.fromJson(json['loanInterestPeriod']),
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      reason: json['reason'] ?? '',
      createdAt: parsedDate,
    );
  }
}