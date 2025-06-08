import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/dropdown_field.dart';
import 'package:lmb_skripsi/components/text_field.dart';
import 'package:lmb_skripsi/helpers/logic/remote_config_service.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/model/lmb_loan_interest.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  late final LmbLoanInterestConfig loanConfig;
  final loanAmountController = TextEditingController();
  final reasonController = TextEditingController();

  List<String> timePeriodList = [];
  String? selectedTimePeriod;
  double? selectedInterest;
  double totalInterest = 0;
  double totalLoan = 0;
  double monthlyInstallment = 0;

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
    final months = int.parse(selectedTimePeriod!.split(' ').first);
    final rate = selectedInterest! / 100;

    setState(() {
      totalInterest = amount * rate * (months / 12);
      totalLoan = amount + totalInterest;
      monthlyInstallment = totalLoan / months;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      title: "Loan",
      useLargeAppBar: true,
      showBackButton: false,
      children: [
        LmbTextField(
          hint: "Loan Amount",
          useLabel: true,
          controller: loanAmountController,
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        LmbTextField(
          hint: "Reason",
          useLabel: true,
          controller: reasonController,
          inputType: TextInputType.text,
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
        const SizedBox(height: 64),

        // NOTE: Bagian summary card
        LmbCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Interest Percentage"),
                  Text(ValueFormatter.formatPercent((selectedInterest ?? 0)/100))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Total Interest"),
                  Text(ValueFormatter.formatPriceIDR(totalInterest))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Total loan"),
                  Text(ValueFormatter.formatPriceIDR(totalLoan))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Monthly Installment"),
                  Text(ValueFormatter.formatPriceIDR(monthlyInstallment))
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}