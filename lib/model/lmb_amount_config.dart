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
      minLoanAmount: json['min_loan_amount'] ?? 100000,
      maxLoanAmount: json['max_loan_amount'] ?? 10000000,
      mandatorySavingAmount: json['mandatory_saving_amount'] ?? 650000,
      principalSavingAmount: json['principal_saving_amount'] ?? 50000,
    );
  }
}