// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/enum/lmb_saving_type.dart';
import 'package:lmb_skripsi/helpers/logic/firestore_service.dart';
import 'package:lmb_skripsi/helpers/logic/remote_config_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/model/lmb_amount_config.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_saving_history.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_mandatory_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_principal_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_voluntary_saving.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';
import 'package:lmb_skripsi/pages/main/children/saving/children/deposit_page.dart';

class SavingPage extends StatefulWidget {
  static final GlobalKey<_SavingPageState> savingpageKey = GlobalKey<_SavingPageState>();
  SavingPage({Key? key}) : super(key: savingpageKey);

  static void refresh() {
    savingpageKey.currentState?.loadSavingData();
  }

  @override
  State<SavingPage> createState() => _SavingPageState();
}

class _SavingPageState extends State<SavingPage> with AutomaticKeepAliveClientMixin {
  late final PageController pageController;
  late LmbAmountConfig amountConfig;
  late Map<LmbSavingType, double> savings;
  late List<LmbSavingHistory> allHistory;
  late LmbMandatorySaving mandatorySaving;
  late LmbPrincipalSaving principalSaving;
  late LmbVoluntarySaving voluntarySaving;
  late DateTime userCreatedDate;
  
  int currentIndex = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.95);
    loadSavingData();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> loadSavingData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final fetchedAmountConfig = await RemoteConfigService.instance.get<LmbAmountConfig>(
        'amount_config',
        (json) => LmbAmountConfig.fromJson(json),
      );

      final user = await LmbLocalStorage.getValue<LmbUser>(
        "user_data",
        fromJson: (json) => LmbUser.fromJson(json),
      );

      final results = await Future.wait([
        FirestoreService.instance.getMandatorySaving(user?.nik ?? ""),
        FirestoreService.instance.getPrincipalSaving(user?.nik ?? ""),
        FirestoreService.instance.getVoluntarySaving(user?.nik ?? ""),
      ]);

      final fetchedMandatorySaving = results[0] as LmbMandatorySaving;
      final fetchedPrincipalSaving = results[1] as LmbPrincipalSaving;
      final fetchedVoluntarySaving = results[2] as LmbVoluntarySaving;

      final fetchedSavings = {
        LmbSavingType.mandatory: fetchedMandatorySaving.totalAmount,
        LmbSavingType.principal: fetchedPrincipalSaving.totalAmount,
        LmbSavingType.voluntary: fetchedVoluntarySaving.totalAmount,
      };

      final List<LmbSavingHistory> combinedHistory = [
        ...fetchedMandatorySaving.history.map((e) => e.copyWith(type: LmbSavingType.mandatory)),
        ...fetchedPrincipalSaving.history.map((e) => e.copyWith(type: LmbSavingType.principal)),
        ...fetchedVoluntarySaving.history.map((e) => e.copyWith(type: LmbSavingType.voluntary)),
      ];
      combinedHistory.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        amountConfig = fetchedAmountConfig;
        userCreatedDate = user?.createdAt ?? DateTime.now();
        mandatorySaving = fetchedMandatorySaving;
        principalSaving = fetchedPrincipalSaving;
        voluntarySaving = fetchedVoluntarySaving;
        savings = fetchedSavings;
        allHistory = combinedHistory;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load saving data: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return LmbBaseElement(
      title: "Saving",
      useLargeAppBar: true,
      showBackButton: false,
      usePadding: false,
      isScrollable: false,
      children: [
        if (errorMessage != null) Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loadSavingData,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ) else ...[
          Container(
            padding: const EdgeInsets.only(top: 12),
            height: 110,
            child: PageView.builder(
              itemCount: savings.length,
              controller: pageController,
              physics: const PageScrollPhysics(),
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                final entry = savings.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: LmbCard(
                    isFullWidth: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              entry.key.label,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              ValueFormatter.formatPriceIDR(entry.value),
                              style: Theme.of(context).textTheme.displaySmall,
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            if (
                              (entry.key == LmbSavingType.mandatory && !(mandatorySaving.isPaid))
                              || (entry.key == LmbSavingType.principal && !(principalSaving.isThisMonthPaid(userCreatedDate)))
                            ) Icon(
                              Icons.warning_rounded,
                              color: (
                                (entry.key == LmbSavingType.mandatory && mandatorySaving.isOverdue(userCreatedDate, amountConfig.mandatorySavingDueInDays))
                                || (entry.key == LmbSavingType.principal && principalSaving.isOverdue(userCreatedDate, amountConfig.principalSavingDueInDays))
                              ) ? LmbColors.error : LmbColors.warning,
                              size: 24,
                            ),
                            if (
                              (entry.key == LmbSavingType.mandatory && !(mandatorySaving.isPaid))
                              || (entry.key == LmbSavingType.principal && !(principalSaving.isThisMonthPaid(userCreatedDate)))
                            ) Text(
                              (
                                (entry.key == LmbSavingType.mandatory && mandatorySaving.isOverdue(userCreatedDate, amountConfig.mandatorySavingDueInDays))
                                || (entry.key == LmbSavingType.principal && principalSaving.isOverdue(userCreatedDate, amountConfig.principalSavingDueInDays))
                              ) ? "Deposit Overdue" : "Need Actions",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: (
                                  (entry.key == LmbSavingType.mandatory && mandatorySaving.isOverdue(userCreatedDate, amountConfig.mandatorySavingDueInDays))
                                  || (entry.key == LmbSavingType.principal && principalSaving.isOverdue(userCreatedDate, amountConfig.principalSavingDueInDays))
                                ) ? LmbColors.error : LmbColors.warning,
                                fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                savings.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LmbPrimaryButton(
              text: "Deposit",
              isFullWidth: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DepositPage(
                    mandatorySaving: mandatorySaving,
                    principalSaving: principalSaving,
                    voluntarySaving: voluntarySaving,
                    amountConfig: amountConfig,
                  )),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
            child: Text("Deposit History", style: Theme.of(context).textTheme.labelMedium),
          ),
          if (allHistory.isEmpty) const Padding(
            padding: EdgeInsets.only(top: 36),
            child: Center(
              child: Text(
                "You haven't done any deposit in the past.",
                textAlign: TextAlign.center,
              ),
            ),
          ) else SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: allHistory.map((history) {
                  return LmbCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "+${ValueFormatter.formatPriceIDR(history.amount)}",
                          style: TextStyle(
                            color: LmbColors.success,
                            fontSize: 24,
                            fontWeight: FontWeight.w600
                          ),
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(history.type?.label ?? "Deposit"),
                            Text(DateFormat('dd MMMM yyyy').format(history.date)),
                          ],
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ]
    );
  }
}