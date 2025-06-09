import 'package:lmb_skripsi/model/lmb_loan_interest.dart';

class LmbLoanInterestConfig {
  final List<LmbLoanInterest> timePeriods;

  LmbLoanInterestConfig({required this.timePeriods});

  factory LmbLoanInterestConfig.fromJson(Map<String, dynamic> json) {
    final List<dynamic> periodsJson = json['time_periods'];
    final timePeriods = periodsJson
        .map((e) => LmbLoanInterest.fromJson(e as Map<String, dynamic>))
        .toList();
    return LmbLoanInterestConfig(timePeriods: timePeriods);
  }
}
