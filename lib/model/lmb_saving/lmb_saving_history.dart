import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lmb_skripsi/enum/lmb_saving_type.dart';

class LmbSavingHistory {
  final LmbSavingType? type;
  final double amount;
  final DateTime date;

  LmbSavingHistory({required this.amount, required this.date, this.type});

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

  LmbSavingHistory copyWith({
    LmbSavingType? type,
  }) {
    return LmbSavingHistory(
      type: type ?? this.type,
      amount: amount,
      date: date
    );
  }
}