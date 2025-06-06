import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/dropdown_field.dart';
import 'package:lmb_skripsi/components/text_field.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final employeeNumberController = TextEditingController();
  final nameController = TextEditingController();
  final loanAmountController = TextEditingController();
  final reasonController = TextEditingController();
  final timePeriodList = ["1 Month", "2 Month", "3 Month", "6 Months", "12 Months", "24 Months"];
  String? selectedTimePeriod;
  final loanInterestController = TextEditingController();
  final totalLoanController = TextEditingController();
  final monthlyInstallmentController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      title: "Loan",
      useLargeAppBar: true,
      showBackButton: false,
      children: [
        LmbTextField(
          hint: "Employee Number", 
          useLabel: true,
          controller: employeeNumberController,
          inputType: TextInputType.number,
        ),
        SizedBox(height: 16),

        LmbTextField(
          hint: "Name", 
          useLabel: true,
          controller: employeeNumberController,
          inputType: TextInputType.name,
        ),
        SizedBox(height: 16),

        LmbTextField(
          hint: "Loan Amount", 
          useLabel: true,
          controller: employeeNumberController,
          inputType: TextInputType.number,
        ),
        SizedBox(height: 16),

        LmbTextField(
          hint: "Reason", 
          useLabel: true,
          controller: reasonController,
          inputType: TextInputType.text,
        ),
        SizedBox(height: 16),

        LmbDropdownField(
          hint: "Time Period",
          useLabel: true,
          value: selectedTimePeriod,
          items: timePeriodList,
          onChanged: (value) {
            setState(() {
              selectedTimePeriod = value;
            });
          },
        ),
        SizedBox(height: 16),

        LmbTextField(
          hint: "Loan interest", 
          useLabel: true,
          controller: loanInterestController,
          inputType: TextInputType.number,
        ),
        SizedBox(height: 16),

        LmbTextField(
          hint: "Total loan", 
          useLabel: true,
          controller: totalLoanController,
          inputType: TextInputType.number,
        ),
        SizedBox(height: 16),

        LmbTextField(
          hint: "Monthly Installment", 
          useLabel: true,
          controller: monthlyInstallmentController,
          inputType: TextInputType.number,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}