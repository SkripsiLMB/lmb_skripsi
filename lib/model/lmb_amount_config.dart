class LmbAmountConfig {
  final double minLoanAmount;
  final double maxLoanAmount;
  final double mandatorySavingAmount;
  final int mandatorySavingDueInDays;
  final double mandatorySavingOverdueFinePercent;
  final double principalSavingAmount;
  final int principalSavingDueInDays;
  final double principalSavingOverdueFinePercent;

  LmbAmountConfig({
    required this.minLoanAmount,
    required this.maxLoanAmount,
    required this.mandatorySavingAmount,
    required this.mandatorySavingDueInDays,
    required this.mandatorySavingOverdueFinePercent,
    required this.principalSavingAmount,
    required this.principalSavingDueInDays,
    required this.principalSavingOverdueFinePercent,
  });

  factory LmbAmountConfig.fromJson(Map<String, dynamic> json) {
    return LmbAmountConfig(
      minLoanAmount: (json['min_loan_amount'] as num?)?.toDouble() ?? 100000,
      maxLoanAmount: (json['max_loan_amount'] as num?)?.toDouble() ?? 10000000,
      mandatorySavingAmount: (json['mandatory_saving_amount'] as num?)?.toDouble() ?? 650000,
      principalSavingAmount: (json['principal_saving_amount'] as num?)?.toDouble() ?? 50000,
      mandatorySavingDueInDays: (json['mandatory_saving_due_in_days'] as num?)?.toInt() ?? 30,
      mandatorySavingOverdueFinePercent: (json['mandatory_saving_overdue_fine_in_percent'] as num?)?.toDouble() ?? 50,
      principalSavingDueInDays: (json['principal_saving_due_in_days'] as num?)?.toInt() ?? 10,
      principalSavingOverdueFinePercent: (json['principal_saving_overdue_fine_in_percent'] as num?)?.toDouble() ?? 5,
    );
  }
}