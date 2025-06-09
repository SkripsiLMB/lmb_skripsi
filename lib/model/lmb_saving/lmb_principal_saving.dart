import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving.dart';

class PrincipalSaving extends LmbSaving {
  final int monthlyAmount;
  final DateTime? lastPaidAt;

  PrincipalSaving({
    required int totalAmount,
    required this.monthlyAmount,
    this.lastPaidAt,
  }) : super(totalAmount, LmbSavingType.principal);

  factory PrincipalSaving.fromJson(Map<String, dynamic> json) {
    return PrincipalSaving(
      totalAmount: json['total_amount'] ?? 0,
      monthlyAmount: json['monthly_amount'] ?? 0,
      lastPaidAt: (json['last_paid_at'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'total_amount': totalAmount,
      'monthly_amount': monthlyAmount,
      'last_paid_at': lastPaidAt != null ? Timestamp.fromDate(lastPaidAt!) : null,
    };
  }

  bool get isDue {
    if (lastPaidAt == null) return true;
    return DateTime.now().difference(lastPaidAt!).inDays >= 30;
  }
}