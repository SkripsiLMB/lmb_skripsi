class LmbAmountConfig {
  final double minLoanAmount;
  final double maxLoanAmount;
  final double mandatorySavingAmount;
  final double principalSavingAmount;

  LmbAmountConfig({
    required this.minLoanAmount,
    required this.maxLoanAmount,
    required this.mandatorySavingAmount,
    required this.principalSavingAmount,
  });

  factory LmbAmountConfig.fromJson(Map<String, dynamic> json) {
    return LmbAmountConfig(
      minLoanAmount: (json['min_loan_amount'] as num?)?.toDouble() ?? 100000,
      maxLoanAmount: (json['max_loan_amount'] as num?)?.toDouble() ?? 10000000,
      mandatorySavingAmount: (json['mandatory_saving_amount'] as num?)?.toDouble() ?? 650000,
      principalSavingAmount: (json['principal_saving_amount'] as num?)?.toDouble() ?? 50000,
    );
  }
}