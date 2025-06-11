import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/dropdown_field.dart';
import 'package:lmb_skripsi/components/info_detail.dart';
import 'package:lmb_skripsi/components/text_field.dart';
import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/model/lmb_amount_config.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_mandatory_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_principal_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_voluntary_saving.dart';

class DepositPage extends StatefulWidget {
  LmbMandatorySaving mandatorySaving;
  LmbPrincipalSaving principalSaving;
  LmbVoluntarySaving voluntarySaving;
  LmbAmountConfig amountConfig;
  DateTime userCreatedDate;

  DepositPage({
    super.key,
    required this.mandatorySaving,
    required this.principalSaving,
    required this.voluntarySaving,
    required this.amountConfig,
    required this.userCreatedDate
  });

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  LmbSavingType? selectedSavingType;
  final TextEditingController voluntaryAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      selectedSavingType = LmbSavingType.mandatory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      title: "Deposit",

      bottomStickyCardItem: LmbPrimaryButton(
        text: "Pay Deposit", 
        onPressed: () {
          
        }
      ),

      children: [
        // NOTE: Pilih type saving
        LmbDropdownField(
          hint: "Saving Type",
          useLabel: true,
          value: selectedSavingType?.label,
          items: LmbSavingType.values.map((e) => e.label).toList(),
          onChanged: (value) {
            setState(() {
              selectedSavingType = LmbSavingType.fromLabel(value ?? "");
            });
          },
        ),

        Padding(
          padding: EdgeInsetsGeometry.only(top: 16, bottom: 8),
          child: Divider(
            color: Theme.of(context).textTheme.bodyMedium?.color ?? LmbColors.darkTextLow,
          ),
        ),
        
        if (selectedSavingType == LmbSavingType.mandatory) _buildMandatorySection()
        else if (selectedSavingType == LmbSavingType.principal) _buildPrincipalSection()
        else if (selectedSavingType == LmbSavingType.voluntary) _buildVoluntarySection(),
      ],
    );
  }

  // NOTE: Mandatory
  Widget _buildMandatorySection() {
    final isOverdue = widget.mandatorySaving.isOverdue(widget.userCreatedDate, widget.amountConfig.principalSavingDueInDays);
    final finePercentage = isOverdue ? widget.amountConfig.mandatorySavingOverdueFinePercent : 0;
    final totalFineValue = widget.amountConfig.mandatorySavingAmount * (finePercentage/100);
    final totalChargedValue = widget.amountConfig.mandatorySavingAmount + totalFineValue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text("Mandatory Savings", style: Theme.of(context).textTheme.labelMedium),
        LmbCard(
          isFullWidth: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              LmbInfoDetail(title: "Current Amount", value: ValueFormatter.formatPriceIDR(widget.mandatorySaving.totalAmount)),
              LmbInfoDetail(
                title: "Deposit Status", 
                value: widget.mandatorySaving.isPaid 
                  ? "Paid"
                  : isOverdue
                    ? "Overdue"
                    : "Unpaid"
              ),
            ],
          ),
        ),

        if (!widget.mandatorySaving.isPaid) LmbCard(
          isFullWidth: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              LmbInfoDetail(title: "Base Value", value: ValueFormatter.formatPriceIDR(widget.amountConfig.mandatorySavingAmount)),
              LmbInfoDetail(title: "Fine Percentage", value: "$finePercentage%"),
              LmbInfoDetail(title: "Fine Value", value: ValueFormatter.formatPriceIDR(totalFineValue)),
              Divider(color: Theme.of(context).textTheme.bodyMedium?.color ?? LmbColors.darkTextLow),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Total",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    ValueFormatter.formatPriceIDR(totalChargedValue),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ]
              ),
            ],
          ),
        ),
      ],
    );
  }

  // NOTE: Principal
  Widget _buildPrincipalSection() {
    final unpaidCount = widget.principalSaving.countUnpaidMonthsIncludingCurrent(widget.userCreatedDate);
    final isThisMonthPaid = widget.principalSaving.isThisMonthPaid(widget.userCreatedDate);
    final isOverdue = widget.principalSaving.isOverdue(widget.userCreatedDate, widget.amountConfig.principalSavingDueInDays);
    final baseValue = widget.amountConfig.principalSavingAmount;
    final finePercentage = isOverdue ? widget.amountConfig.principalSavingOverdueFinePercent : 0;
    final baseTotal = unpaidCount * baseValue;
    final finalValue = isOverdue ? baseTotal * pow((1 + finePercentage / 100), unpaidCount) : baseTotal;
    final totalFineValue = finalValue - baseTotal;
    final totalChargedValue = finalValue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text("Principal Savings", style: Theme.of(context).textTheme.labelMedium),
        LmbCard(
          isFullWidth: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              LmbInfoDetail(title: "Current Amount", value: ValueFormatter.formatPriceIDR(widget.principalSaving.totalAmount)),
              LmbInfoDetail(
                title: "Deposit Status", 
                value: isThisMonthPaid 
                  ? "Paid" 
                  : unpaidCount > 1 
                    ? "$unpaidCount Months Overdue"
                    : isOverdue
                      ? "Overdue"
                      : "Unpaid"
              ),
              LmbInfoDetail(title: "Deposit Frequency", value: "${widget.principalSaving.history.length}x"),
            ],
          ),
        ),

        if (!isThisMonthPaid) LmbCard(
          isFullWidth: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              LmbInfoDetail(title: "Base Value", value: ValueFormatter.formatPriceIDR(widget.amountConfig.principalSavingAmount)),
              LmbInfoDetail(title: "Unpaid Deposits", value: "${unpaidCount}x"),
              LmbInfoDetail(title: "Fine Percentage Monthly", value: "$finePercentage%"),
              LmbInfoDetail(title: "Fine Value", value: ValueFormatter.formatPriceIDR(totalFineValue)),
              Divider(color: Theme.of(context).textTheme.bodyMedium?.color ?? LmbColors.darkTextLow),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Total",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    ValueFormatter.formatPriceIDR(totalChargedValue),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ]
              ),
            ],
          ),
        ),
      ],
    );
  }

  // NOTE: Voluntary
  Widget _buildVoluntarySection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text("Voluntary Savings", style: Theme.of(context).textTheme.labelMedium),
        LmbCard(
          isFullWidth: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              LmbInfoDetail(title: "Current Amount", value: ValueFormatter.formatPriceIDR(widget.voluntarySaving.totalAmount)),
              LmbInfoDetail(title: "Deposit Frequency", value: "${widget.voluntarySaving.history.length}x"),
            ],
          ),
        ),

        LmbTextField(
          hint: "Amount to Deposit", 
          controller: voluntaryAmountController,
          inputType: TextInputType.number,
          prefixIcon: SvgPicture.asset(
            'assets/rupiah_icon.svg',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        )
      ],
    );
  }
}