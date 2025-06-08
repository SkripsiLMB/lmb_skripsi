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
      annualInterestRate: (json['annualInterestRate'] as num).toDouble(),
    );
  }

  @override
  String toString() => "$months Month";
}

class LmbLoanInterestConfig {
  final List<LmbLoanInterest> timePeriods;

  LmbLoanInterestConfig({required this.timePeriods});

  factory LmbLoanInterestConfig.fromJson(Map<String, dynamic> json) {
    final List<dynamic> periodsJson = json['timePeriods'];
    final timePeriods = periodsJson
        .map((e) => LmbLoanInterest.fromJson(e as Map<String, dynamic>))
        .toList();
    return LmbLoanInterestConfig(timePeriods: timePeriods);
  }
}

