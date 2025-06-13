import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/checkbox.dart';
import 'package:lmb_skripsi/components/info_detail.dart';
import 'package:lmb_skripsi/helpers/logic/firestore_service.dart';
import 'package:lmb_skripsi/helpers/logic/loan_calculator.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/model/lmb_loan.dart';
import 'package:lmb_skripsi/pages/main/children/home/home_page.dart';

class LoanConfirmationPage extends StatefulWidget {
  LmbLoan model;
  
  LoanConfirmationPage({
    super.key,
    required this.model
  });

  @override
  State<LoanConfirmationPage> createState() => _LoanConfirmationPageState();
}

class _LoanConfirmationPageState extends State<LoanConfirmationPage> {
  late double totalInterest;
  late double totalLoan;
  late double monthlyInstallment;
  bool confirmCorrectInformation = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    totalInterest = LoanCalculator.calculateInterest(widget.model);
    totalLoan = LoanCalculator.calculateTotalLoan(widget.model);
    monthlyInstallment = LoanCalculator.calculateMonthlyInstallment(widget.model);
  }
  
  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      title: "Loan Confirmation",

      bottomStickyCardItem: LmbPrimaryButton(
        text: "Confirm Your Loan", 
        isFullWidth: true,
        isLoading: isLoading,
        onPressed: () async {
          if (!confirmCorrectInformation) {
            WindowProvider.toastError(context, "Please check the statement box");
            return;
          }

          setState(() => isLoading = true);
          await FirestoreService.instance.addLoanToUser(widget.model);
          setState(() => isLoading = false);
          WindowProvider.toastSuccess(context, "Successfully applied for a loan.");
          Homepage.refresh();
          Navigator.of(context).pop();
        }
      ),

      children: [
        Text(
          "Please review your loan details carefully before proceeding. Any incorrect or incomplete information provided is solely your responsibility, and the company will not be held accountable for any consequences resulting from such errors.",
          textAlign: TextAlign.justify,  
        ),
        const SizedBox(height: 32),

        Text(
          "Applier",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        LmbCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LmbInfoDetail(
                title: "Name",
                value: widget.model.loanMaker.name,
              ),
              LmbInfoDetail(
                title: "NIK",
                value: widget.model.loanMaker.nik,
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 4),
                child: Divider(
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? LmbColors.darkTextLow,
                ),
              ),
              LmbInfoDetail(
                title: "Bank Name",
                value: widget.model.bankName,
              ),
              LmbInfoDetail(
                title: "Bank Account Number",
                value: widget.model.bankAccountNumber,
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 4),
                child: Divider(
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? LmbColors.darkTextLow,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reason of apply:",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    widget.model.reason,
                    textAlign: TextAlign.justify,
                  )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "Requested",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        LmbCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LmbInfoDetail(
                title: "Loan Amount",
                value: ValueFormatter.formatPriceIDR(widget.model.loanAmount),
              ),
              LmbInfoDetail(
                title: "Time Period",
                value: "${widget.model.loanInterestPeriod.months} Month(s)",
              ),
              LmbInfoDetail(
                title: "Interest Percentage",
                value: ValueFormatter.formatPercent((widget.model.loanInterestPeriod.annualInterestRate)/100),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "Summary",
          style: Theme.of(context).textTheme.labelMedium,
        ),
        LmbCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
        const SizedBox(height: 32),

        LmbCheckbox.element(
          value: confirmCorrectInformation, 
          onChanged: (val) => setState(() => confirmCorrectInformation = val ?? false), 
          element: Expanded(
            child: Text(
              "I hereby confirm that all the information provided above is true and correct.",
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}