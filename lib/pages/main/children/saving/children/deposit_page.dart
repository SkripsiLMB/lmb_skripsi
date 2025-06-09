import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/dropdown_field.dart';
import 'package:lmb_skripsi/components/info_detail.dart';
import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  LmbSavingType? selectedSavingType = LmbSavingType.mandatory;

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
          padding: EdgeInsetsGeometry.symmetric(vertical: 4),
          child: Divider(
            color: Theme.of(context).textTheme.bodyMedium?.color ?? LmbColors.darkTextLow,
          ),
        ),
        
        // NOTE: Mandatory
        if (selectedSavingType == LmbSavingType.mandatory) ...[
          Text(
            "Mandatory Savings",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: 8),
          LmbCard(
            isFullWidth: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LmbInfoDetail(
                  title: "Total Deposits",
                  titleStyle: Theme.of(context).textTheme.labelMedium, 
                  value: ValueFormatter.formatPriceIDR(0),
                  valueStyle: Theme.of(context).textTheme.labelLarge
                ),
              ],
            ),
          ),
        ],

        // NOTE: Principal
        if (selectedSavingType == LmbSavingType.principal) ...[
          Text(
            "Principal Savings",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: 8),
          LmbCard(
            isFullWidth: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Total Deposits",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      ValueFormatter.formatPriceIDR(0),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],

        // NOTE: Voluntary
        if (selectedSavingType == LmbSavingType.voluntary) ...[
          Text(
            "Voluntary Savings",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: 8),
          LmbCard(
            isFullWidth: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Total Deposits",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      ValueFormatter.formatPriceIDR(0),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ],
    );
  }
}