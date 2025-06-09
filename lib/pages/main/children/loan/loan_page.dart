import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/dropdown_field.dart';
import 'package:lmb_skripsi/components/info_detail.dart';
import 'package:lmb_skripsi/components/text_field.dart';
import 'package:lmb_skripsi/helpers/logic/input_validator.dart';
import 'package:lmb_skripsi/helpers/logic/loan_calculator.dart';
import 'package:lmb_skripsi/helpers/logic/remote_config_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/model/lmb_amount_config.dart';
import 'package:lmb_skripsi/model/lmb_loan.dart';
import 'package:lmb_skripsi/model/lmb_loan_interest.dart';
import 'package:lmb_skripsi/model/lmb_loan_interest_config.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';
import 'package:lmb_skripsi/pages/main/children/loan/children/loan_confirmation_page.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  late final LmbLoanInterestConfig loanConfig;
  final loanAmountController = TextEditingController();
  final reasonController = TextEditingController();
  final bankAccountNumberController = TextEditingController();

  List<String> timePeriodList = [];
  String? selectedTimePeriod;
  double? selectedInterest;
  double totalInterest = 0;
  double totalLoan = 0;
  double monthlyInstallment = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeLoanConfig();
  }

  // NOTE: Ambil ulang takutnya ada perubahan dalam waktu dekat
  Future<void> _initializeLoanConfig() async {
    final config = await RemoteConfigService.instance.get<LmbLoanInterestConfig>(
      'loan_interest_config',
      (json) => LmbLoanInterestConfig.fromJson(json)
    );
    setState(() {
      loanConfig = config;
      timePeriodList = loanConfig.timePeriods.map((e) => "${e.months} Month").toList();
    });
    loanAmountController.addListener(_updateCalculations);
  }

  // NOTE: Ambil ulang takutnya ada perubahan dalam waktu dekat
  void _updateCalculations() {
    if (loanAmountController.text.isEmpty || selectedInterest == null || selectedTimePeriod == null) return;

    final amount = double.tryParse(loanAmountController.text) ?? 0;
    final months = int.tryParse(selectedTimePeriod!.split(' ').first) ?? 0;

    final interest = LoanCalculator.calculateInterestLocal(amount, selectedInterest!, months);
    final loan = LoanCalculator.calculateTotalLoanLocal(amount, interest);
    final installment = LoanCalculator.calculateMonthlyInstallmentLocal(loan, months);

    setState(() {
      totalInterest = interest;
      totalLoan = loan;
      monthlyInstallment = installment;
    });
}

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      title: "Loan",
      useLargeAppBar: true,
      showBackButton: false,
      children: [
        // NOTE: Form loan
        LmbTextField(
          hint: "Loan Amount",
          useLabel: true,
          controller: loanAmountController,
          inputType: TextInputType.number,
          prefixIcon: SvgPicture.asset(
            'assets/rupiah_icon.svg',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),


        LmbDropdownField(
          hint: "Time Period",
          useLabel: true,
          value: selectedTimePeriod,
          items: timePeriodList,
          onChanged: (value) {
            setState(() {
              selectedTimePeriod = value;
              final selected = loanConfig.timePeriods.firstWhere(
                (e) => "$e" == value,
                orElse: () => loanConfig.timePeriods.first,
              );
              selectedInterest = selected.annualInterestRate;
              _updateCalculations();
            });
          },
        ),
        const SizedBox(height: 16),

        // NOTE: Bagian summary card
        Text(
            "Loan Summary",
            style: Theme.of(context).textTheme.labelMedium,
          ),
        const SizedBox(height: 8),
        LmbCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LmbInfoDetail(
                title: "Interest Percentage",
                value: ValueFormatter.formatPercent((selectedInterest ?? 0)/100),
              ),
              LmbInfoDetail(
                title: "Total Interest",
                value: ValueFormatter.formatPriceIDR(totalInterest),
              ),
              LmbInfoDetail(
                title: "Total Loan",
                value: ValueFormatter.formatPriceIDR(totalLoan),
              ),
              LmbInfoDetail(
                title: "Monthly Installment",
                value: ValueFormatter.formatPriceIDR(monthlyInstallment),
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsetsGeometry.fromLTRB(0, 16, 0, 12),
          child: Divider(
            color: Theme.of(context).textTheme.bodyMedium?.color ?? LmbColors.darkTextLow,
          ),
        ),

        // NOTE: Form Tambahan
        LmbTextField(
          hint: "BCA Account Number",
          useLabel: true,
          controller: bankAccountNumberController,
          inputType: TextInputType.number,
          suffixIcon: SvgPicture.asset(
            'assets/bca_logo_icon.svg',
            width: 48,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),

        LmbTextField(
          hint: "Reason",
          useLabel: true,
          controller: reasonController,
          inputType: TextInputType.text,
          height: 120,
        ),
        const SizedBox(height: 32),

        LmbPrimaryButton(
          text: "Apply Loan", 
          isLoading: isLoading,
          isFullWidth: true,
          onPressed: () async {
            setState(() => isLoading = true);
            final userData = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
            setState(() => isLoading = false);
            if (userData == null) {
              WindowProvider.toastError(context, "Something went wrong");
              return;
            }

            final loanAmount = loanAmountController.text.trim();
            final config = await RemoteConfigService.instance.get<LmbAmountConfig>(
              'amount_config',
              (json) => LmbAmountConfig.fromJson(json),
            );
            final loanAmountError = InputValidator.number(
              loanAmount,
              "Loan Amount",
              minValue: config.minLoanAmount,
              maxValue: config.maxLoanAmount,
            );
            if (loanAmountError != null) {
              WindowProvider.toastError(context, loanAmountError);
              return;
            }

            if (selectedTimePeriod == null) {
              WindowProvider.toastError(context, "Please select a time period.");
              return;
            }

            final bankAccountNumber = bankAccountNumberController.text.trim();
            final bankAccountNumberError = InputValidator.number(bankAccountNumber, "BCA Account Number", minLen: 10, maxLen: 10);
            if (bankAccountNumberError != null) {
              WindowProvider.toastError(context, bankAccountNumberError);
              return;
            }

            final reason = reasonController.text.trim();
            final reasonError = InputValidator.empty(reason, "Reason", maxLen: 512);
            if (reasonError != null) {
              WindowProvider.toastError(context, reasonError);
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoanConfirmationPage(
                  model: LmbLoan(
                    loanMaker: userData, 
                    loanAmount: double.tryParse(loanAmountController.text) ?? 0, 
                    loanInterestPeriod: LmbLoanInterest(
                      months: int.tryParse(selectedTimePeriod?.split(' ').first ?? '0') ?? 0, 
                      annualInterestRate: selectedInterest ?? 0
                    ), 
                    bankAccountNumber: bankAccountNumber, 
                    paymentCounter: 0,
                    reason: reason
                  ),
                ),
              ),
            );
          }
        ),
      ],
    );
  }
}