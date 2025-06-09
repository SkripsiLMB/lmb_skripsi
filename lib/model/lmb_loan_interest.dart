class LmbLoanInterest {
  final int months;
  final double annualInterestRate;

  LmbLoanInterest({
    required this.months,
    required this.annualInterestRate,
  });

  factory LmbLoanInterest.fromJson(Map<String, dynamic> json) {
    return LmbLoanInterest(
      months: json['months'] as int,
      annualInterestRate: (json['annual_interest_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'months': months,
      'annual_interest_rate': annualInterestRate,
    };
  }

  @override
  String toString() => "$months Month";
}
