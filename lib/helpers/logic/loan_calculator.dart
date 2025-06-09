class LoanCalculator {
  static double calculateInterest(double amount, double annualRate, int months) {
    return amount * (annualRate / 100) * (months / 12);
  }

  static double calculateTotalLoan(double amount, double interest) {
    return amount + interest;
  }

  static double calculateMonthlyInstallment(double totalLoan, int months) {
    return totalLoan / months;
  }
}