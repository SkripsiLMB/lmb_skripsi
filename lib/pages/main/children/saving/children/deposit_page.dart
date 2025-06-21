import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/dropdown_field.dart';
import 'package:lmb_skripsi/components/info_detail.dart';
import 'package:lmb_skripsi/components/payment_qr.dart';
import 'package:lmb_skripsi/components/text_field.dart';
import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/helpers/logic/firestore_service.dart';
import 'package:lmb_skripsi/helpers/logic/input_validator.dart';
import 'package:lmb_skripsi/helpers/logic/saving_calculator.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/model/lmb_amount_config.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_mandatory_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_principal_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_voluntary_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving_calculation_result.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';
import 'package:lmb_skripsi/pages/main/children/home/home_page.dart';
import 'package:lmb_skripsi/pages/main/children/saving/saving_page.dart';

class DepositPage extends StatefulWidget {
  LmbMandatorySaving mandatorySaving;
  LmbPrincipalSaving principalSaving;
  LmbVoluntarySaving voluntarySaving;
  LmbAmountConfig amountConfig;
  LmbSavingType selectedType;

  DepositPage({
    super.key,
    required this.mandatorySaving,
    required this.principalSaving,
    required this.voluntarySaving,
    required this.amountConfig,
    required this.selectedType
  });

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  LmbSavingType? selectedSavingType;
  final TextEditingController voluntaryAmountController = TextEditingController();
  late final LmbMandatorySaving mandatorySaving;
  late final LmbPrincipalSaving principalSaving;
  late final LmbVoluntarySaving voluntarySaving;
  late final LmbSavingCalculationResult mandatorySavingCalculation;
  late final LmbSavingCalculationResult principalSavingCalculation;
  late final LmbUser userData;
  bool isLoading = false;
  bool isActionLoading = false;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    if (mounted) {
      selectedSavingType = widget.selectedType;
    }
  }

  Future<void> fetchInitialData() async {
    setState(() => isLoading = true);

    final fetchedUserData = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));

    if (fetchedUserData == null) {
      WindowProvider.toastError(context, "Something went wrong");
      return;
    }

    setState(() {
      isLoading = false;
      userData = fetchedUserData;

      mandatorySaving = widget.mandatorySaving;
      principalSaving = widget.principalSaving;
      voluntarySaving = widget.voluntarySaving;

      mandatorySavingCalculation = LmbSavingCalculator.calculateMandatory(
        saving: mandatorySaving, 
        config: widget.amountConfig, 
        userCreatedDate: userData.createdAt
      );
      principalSavingCalculation = LmbSavingCalculator.calculatePrincipal(
        saving: principalSaving, 
        config: widget.amountConfig, 
        userCreatedDate: userData.createdAt
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return LmbBaseElement(
      title: "Deposit",

      bottomStickyCardItem: LmbPrimaryButton(
        text: "Add Funds to Deposit", 
        isLoading: isActionLoading,
        onPressed: () async {
          double paymentAmount = 0;
          switch (selectedSavingType) {
            case LmbSavingType.mandatory:
              paymentAmount = mandatorySavingCalculation.totalValue;
              break;

            case LmbSavingType.principal:
              paymentAmount = principalSavingCalculation.totalValue;
              break;

            case LmbSavingType.voluntary:
              final voluntaryError = InputValidator.number(
                voluntaryAmountController.text, 
                "Deposit Amount", 
                minValue: widget.amountConfig.voluntarySavingMinChargeAmount,
                maxValue: widget.amountConfig.voluntarySavingMaxChargeAmount
              );
              if (voluntaryError != null) {
                WindowProvider.toastError(context, voluntaryError);
                return;
              }
              paymentAmount = double.tryParse(voluntaryAmountController.text) ?? 0;
              break;

            default:
              WindowProvider.toastError(context, "Please select a deposit type");
              return;
          }

          if (paymentAmount == 0) {
            WindowProvider.toastError(context, "You've completed the deposit of this period");
            return;
          }

          setState(() {
            isActionLoading = true;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LmbPaymentQr(
                amount: paymentAmount,
                onPaymentSuccess: () async {
                  await FirestoreService.instance.updateSavingPayment(savingType: selectedSavingType!, amount: paymentAmount, userNik: userData.nik);
                  Homepage.refresh();
                  SavingPage.refresh();
                  Navigator.pop(context);
                  WindowProvider.toastSuccess(context, "Succesfully deposited to ${selectedSavingType?.label ?? "savings"}");
                },
                onPaymentFailed: () {
                  WindowProvider.toastError(context, "Deposit failed or timed out. Please try again.");
                },
              ),
            ),
          ).then((result) {
            FocusScope.of(context).unfocus();
            setState(() => isActionLoading = false);
          });
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
    final isOverdue = mandatorySaving.isOverdue(userData.createdAt, widget.amountConfig.principalSavingDueInDays);

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
              LmbInfoDetail(title: "Current Amount", value: ValueFormatter.formatPriceIDR(mandatorySaving.totalAmount)),
              LmbInfoDetail(
                title: "Deposit Status", 
                value: mandatorySaving.isPaid 
                  ? "Paid"
                  : isOverdue
                    ? "Overdue"
                    : "Unpaid"
              ),
            ],
          ),
        ),

        if (!mandatorySaving.isPaid) LmbCard(
          isFullWidth: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              LmbInfoDetail(title: "Base Value", value: ValueFormatter.formatPriceIDR(mandatorySavingCalculation.baseValue)),
              LmbInfoDetail(title: "Fine Percentage", value: ValueFormatter.formatPercent(mandatorySavingCalculation.finePercentage)),
              LmbInfoDetail(title: "Fine Value", value: ValueFormatter.formatPriceIDR(mandatorySavingCalculation.fineValue)),
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
                    ValueFormatter.formatPriceIDR(mandatorySavingCalculation.totalValue),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ]
              ),
            ],
          ),
        ),
        Text(
          "Mandatory Saving is a required one time contribution that all members must deposit as part of their cooperative obligations. The amount is fixed according to the configuration set by the system. If you fail to deposit by the due date, a fine will be applied based on the number of overdue days. These savings are intended to maintain active membership and support collective financial responsibility among members. You cannot skip or delay this payment without penalty.",
          textAlign: TextAlign.justify,  
        ),
      ],
    );
  }

  // NOTE: Principal
  Widget _buildPrincipalSection() {
    final unpaidCount = principalSaving.countUnpaidMonthsIncludingCurrent(userData.createdAt);
    final isThisMonthPaid = principalSaving.isThisMonthPaid(userData.createdAt);
    final isOverdue = principalSaving.isOverdue(userData.createdAt, widget.amountConfig.principalSavingDueInDays);

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
              LmbInfoDetail(title: "Current Amount", value: ValueFormatter.formatPriceIDR(principalSaving.totalAmount)),
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
              LmbInfoDetail(title: "Deposit Frequency", value: "${principalSaving.history.length}x"),
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
              LmbInfoDetail(title: "Base Value", value: ValueFormatter.formatPriceIDR(principalSavingCalculation.baseValue)),
              LmbInfoDetail(title: "Unpaid Deposits", value: "${unpaidCount}x"),
              LmbInfoDetail(title: "Fine Percentage Monthly", value: ValueFormatter.formatPercent(principalSavingCalculation.finePercentage)),
              LmbInfoDetail(title: "Fine Value", value: ValueFormatter.formatPriceIDR(principalSavingCalculation.fineValue)),
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
                    ValueFormatter.formatPriceIDR(principalSavingCalculation.totalValue),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ]
              ),
            ],
          ),
        ),
        Text(
          "Principal Savings are core monthly deposits that help build the foundation of your personal savings account. These savings accumulate over time and form part of your equity in the cooperative. The deposit is scheduled monthly from the date you joined. If you miss a month, the amount will accumulate, and a fine is applied per unpaid month. It’s important to keep up with this deposit to maintain good standing and maximize long-term savings growth.",
          textAlign: TextAlign.justify,
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
              LmbInfoDetail(title: "Current Amount", value: ValueFormatter.formatPriceIDR(voluntarySaving.totalAmount)),
              LmbInfoDetail(title: "Deposit Frequency", value: "${voluntarySaving.history.length}x"),
            ],
          ),
        ),

        Text(
          "Voluntary Savings offer you the flexibility to deposit any amount you wish within the allowed minimum and maximum limits. Unlike mandatory or principal savings, this deposit is entirely optional and can be made at any time. It’s a great way to increase your total savings, set aside extra funds, or save up for future goals. There are no fines or deadlines — you’re in full control of how much and how often you contribute.",
          textAlign: TextAlign.justify,
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
        ),
      ],
    );
  }
}