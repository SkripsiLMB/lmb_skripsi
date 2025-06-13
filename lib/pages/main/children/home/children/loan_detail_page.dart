import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/info_detail.dart';
import 'package:lmb_skripsi/components/payment_qr.dart';
import 'package:lmb_skripsi/helpers/logic/firestore_service.dart';
import 'package:lmb_skripsi/helpers/logic/loan_calculator.dart';
import 'package:lmb_skripsi/helpers/logic/midtrans_service.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/model/lmb_loan.dart';
import 'package:lmb_skripsi/pages/main/children/home/home_page.dart';

class LoanDetailPage extends StatefulWidget {
  final LmbLoan model;
  const LoanDetailPage({
    super.key,
    required this.model
  });

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  late double totalInterest;
  late double totalLoan;
  late double monthlyInstallment;
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
    final nextDueDate = LoanCalculator.calculateNextPaymentDueDate(widget.model);
    final formattedNextDueDate = nextDueDate != null
        ? DateFormat('dd MMM yyyy').format(nextDueDate)
        : '-';

    return LmbBaseElement(
      title: "Loan Details",

      bottomStickyCardItem: SizedBox(
        height: 100,
        child: Column(
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total payment",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  ValueFormatter.formatPriceIDR(monthlyInstallment),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ]
            ),
            LmbPrimaryButton(
              text: "Pay Now", 
              isFullWidth: true,
              isLoading: isLoading,
              onPressed: () async {
                setState(() => isLoading = true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LmbPaymentQr(
                      amount: monthlyInstallment,
                      onPaymentSuccess: () async {
                        final status = await FirestoreService.instance.payLoanInstallment(widget.model);
                        if (status == null) {
                          WindowProvider.toastError(context, "Successfully paid but isn't registered");
                          
                        } else {
                          WindowProvider.toastSuccess(context, "Successfully paid ${status ? "this month installment" : "whole loan installments"}.");
                          Homepage.refresh();
                          Navigator.of(context).pop();
                        }
                      },
                      onPaymentFailed: () {
                        WindowProvider.toastError(context, "Payment failed or timed out. Please try again.");
                      },
                    ),
                  ),
                ).then((result) {
                  setState(() => isLoading = false);
                });             
              }
            ),
          ],
        ),
      ),

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Next due date",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              formattedNextDueDate,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ]
        ),
        const SizedBox(height: 16),

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
                title: "Total Payment Done",
                value: ValueFormatter.formatPriceIDR(monthlyInstallment * widget.model.paymentCounter),
              ),
              LmbInfoDetail(
                title: "Monthly Installment",
                value: ValueFormatter.formatPriceIDR(monthlyInstallment),
              ),
            ],
          ),
        ),
      ],
    );
  }
}