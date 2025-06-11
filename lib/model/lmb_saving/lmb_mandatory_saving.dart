import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving_history.dart';

class LmbMandatorySaving extends LmbSaving {
  final List<LmbSavingHistory> history;

  LmbMandatorySaving({required double totalAmount, required this.history})
      : super(totalAmount, LmbSavingType.mandatory);

  bool get isPaid => history.isNotEmpty;

  bool isOverdue(DateTime userCreatedDate, int dueDateInDays) {
    final now = DateTime.now();
    final graceEnd = userCreatedDate.add(Duration(days: dueDateInDays));
    final pastGrace = now.isAfter(graceEnd);

    return !isPaid && pastGrace;
  }

  factory LmbMandatorySaving.fromJson(Map<String, dynamic> json) {
    return LmbMandatorySaving(
      totalAmount: (json['total_amount'] as num? ?? 0).toDouble(),
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => LmbSavingHistory.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'total_amount': totalAmount,
        'history': history.map((e) => e.toJson()).toList(),
      };
}