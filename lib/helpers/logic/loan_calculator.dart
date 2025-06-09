import 'package:lmb_skripsi/model/lmb_loan.dart';

class LoanCalculator {
  static double calculateInterestLocal(double amount, double annualRate, int months) {
    return amount * (annualRate / 100) * (months / 12);
  }

  static double calculateTotalLoanLocal(double amount, double interest) {
    return amount + interest;
  }

  static double calculateMonthlyInstallmentLocal(double totalLoan, int months) {
    return totalLoan / months;
  }

  static double calculateInterest(LmbLoan loan) {
    return calculateInterestLocal(
      loan.loanAmount,
      loan.loanInterestPeriod.annualInterestRate,
      loan.loanInterestPeriod.months,
    );
  }

  static double calculateTotalLoan(LmbLoan loan) {
    final interest = calculateInterest(loan);
    return calculateTotalLoanLocal(loan.loanAmount, interest);
  }

  static double calculateMonthlyInstallment(LmbLoan loan) {
    final totalLoan = calculateTotalLoan(loan);
    return calculateMonthlyInstallmentLocal(totalLoan, loan.loanInterestPeriod.months);
  }

  static DateTime? calculateNextPaymentDueDate(LmbLoan model) {
  if (model.createdAt == null) return null;
  final createdAt = model.createdAt!;
  final nextMonth = model.paymentCounter + 1;
  final year = createdAt.year + ((createdAt.month + nextMonth - 1) ~/ 12);
  final month = (createdAt.month + nextMonth - 1) % 12 + 1;

  return DateTime(year, month, createdAt.day);
}

  static int calculateRemainingMonths(LmbLoan loan) {
    return loan.loanInterestPeriod.months - loan.paymentCounter;
  }

  static bool isLoanActive(LmbLoan model) {
    return model.paymentCounter == model.loanInterestPeriod.months;
  }
}