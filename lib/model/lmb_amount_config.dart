class LmbAmountConfig {
  final double minLoanAmount;
  final double maxLoanAmount;
  final double mandatorySavingChargeAmount;
  final int mandatorySavingDueInDays;
  final double mandatorySavingOverdueFinePercent;
  final double principalSavingChargeAmount;
  final int principalSavingDueInDays;
  final double principalSavingOverdueFinePercent;
  final double voluntarySavingMinChargeAmount;
  final double voluntarySavingMaxChargeAmount;

  LmbAmountConfig({
    required this.minLoanAmount,
    required this.maxLoanAmount,
    required this.mandatorySavingChargeAmount,
    required this.mandatorySavingDueInDays,
    required this.mandatorySavingOverdueFinePercent,
    required this.principalSavingChargeAmount,
    required this.principalSavingDueInDays,
    required this.principalSavingOverdueFinePercent,
    required this.voluntarySavingMinChargeAmount,
    required this.voluntarySavingMaxChargeAmount
  });

  factory LmbAmountConfig.fromJson(Map<String, dynamic> json) {
    return LmbAmountConfig(
      minLoanAmount: (json['min_loan_amount'] as num?)?.toDouble() ?? 100000,
      maxLoanAmount: (json['max_loan_amount'] as num?)?.toDouble() ?? 10000000,
      mandatorySavingChargeAmount: (json['mandatory_saving_charge_amount'] as num?)?.toDouble() ?? 650000,
      mandatorySavingDueInDays: (json['mandatory_saving_due_in_days'] as num?)?.toInt() ?? 30,
      mandatorySavingOverdueFinePercent: (json['mandatory_saving_overdue_fine_in_percent'] as num?)?.toDouble() ?? 50,
      principalSavingChargeAmount: (json['principal_saving_charge_amount'] as num?)?.toDouble() ?? 50000,
      principalSavingDueInDays: (json['principal_saving_due_in_days'] as num?)?.toInt() ?? 10,
      principalSavingOverdueFinePercent: (json['principal_saving_overdue_fine_in_percent'] as num?)?.toDouble() ?? 5,
      voluntarySavingMinChargeAmount: (json['voluntary_saving_min_charge_amount'] as num?)?.toDouble() ?? 5000,
      voluntarySavingMaxChargeAmount: (json['voluntary_saving_max_charge_amount'] as num?)?.toDouble() ?? 10000000,
    );
  }
}