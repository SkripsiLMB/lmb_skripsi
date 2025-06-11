import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving_history.dart';

class LmbPrincipalSaving extends LmbSaving {
  final List<LmbSavingHistory> history;

  LmbPrincipalSaving({required double totalAmount, required this.history})
      : super(totalAmount, LmbSavingType.principal);

  bool isThisMonthPaid(DateTime userCreatedDate) {
    final now = DateTime.now();
    final currentDueDate = DateTime(now.year, now.month, userCreatedDate.day);
    return history.any((entry) =>
      entry.date.year == currentDueDate.year &&
      entry.date.month == currentDueDate.month);
  }

  bool isOverdue(DateTime userCreatedDate, int dueDateInDays) {
    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month, userCreatedDate.day);
    final gracePeriodEnd = dueDate.add(Duration(days: dueDateInDays));
    
    final unpaid = !isThisMonthPaid(userCreatedDate);
    final pastGracePeriod = now.isAfter(gracePeriodEnd);
    
    return unpaid && pastGracePeriod;
  }

  int countUnpaidMonthsIncludingCurrent(DateTime userCreatedDate) {
    final now = DateTime.now();
    final firstDue = DateTime(userCreatedDate.year, userCreatedDate.month, userCreatedDate.day);
    final paidMonths = history
        .map((h) => DateTime(h.date.year, h.date.month))
        .toSet();

    int unpaidCount = 0;
    DateTime cursor = firstDue;

    while (cursor.isBefore(DateTime(now.year, now.month + 1))) {
      final monthKey = DateTime(cursor.year, cursor.month);
      if (!paidMonths.contains(monthKey)) {
        unpaidCount++;
      }
      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    return unpaidCount;
  }

  factory LmbPrincipalSaving.fromJson(Map<String, dynamic> json) {
    return LmbPrincipalSaving(
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