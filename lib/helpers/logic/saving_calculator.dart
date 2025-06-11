import 'dart:math';
import 'package:lmb_skripsi/model/lmb_amount_config.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_mandatory_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_principal_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving_calculation_result.dart';

class LmbSavingCalculator {
  static LmbSavingCalculationResult calculateMandatory({
    required LmbMandatorySaving saving,
    required LmbAmountConfig config,
    required DateTime userCreatedDate,
  }) {
    final isOverdue = saving.isOverdue(userCreatedDate, config.principalSavingDueInDays);
    final finePercentage = isOverdue ? config.mandatorySavingOverdueFinePercent : 0.0;
    final fineValue = config.mandatorySavingChargeAmount * (finePercentage / 100);
    final totalValue = config.mandatorySavingChargeAmount + fineValue;

    return LmbSavingCalculationResult(
      baseValue: config.mandatorySavingChargeAmount,
      finePercentage: finePercentage,
      fineValue: fineValue,
      totalValue: saving.isPaid ? 0 : totalValue,
    );
  }

  static LmbSavingCalculationResult calculatePrincipal({
    required LmbPrincipalSaving saving,
    required LmbAmountConfig config,
    required DateTime userCreatedDate,
  }) {
    final unpaidCount = saving.countUnpaidMonthsIncludingCurrent(userCreatedDate);
    final isOverdue = saving.isOverdue(userCreatedDate, config.principalSavingDueInDays);

    final baseValue = config.principalSavingChargeAmount;
    final baseTotal = unpaidCount * baseValue;

    final finePercentage = isOverdue ? config.principalSavingOverdueFinePercent : 0.0;
    final totalValue = isOverdue
        ? baseTotal * pow((1 + finePercentage / 100), unpaidCount)
        : baseTotal;

    final fineValue = totalValue - baseTotal;

    return LmbSavingCalculationResult(
      baseValue: baseValue,
      finePercentage: finePercentage,
      fineValue: fineValue,
      totalValue: saving.isThisMonthPaid(userCreatedDate) ? 0 : totalValue,
    );
  }
}