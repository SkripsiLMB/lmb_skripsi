import 'package:cloud_firestore/cloud_firestore.dart';

class LmbSavingHistory {
  final double amount;
  final DateTime date;

  LmbSavingHistory({required this.amount, required this.date});

  factory LmbSavingHistory.fromJson(Map<String, dynamic> json) {
    return LmbSavingHistory(
      amount: (json['amount'] as num? ?? 0).toDouble(),
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}