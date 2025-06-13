// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/profile_picture.dart';
import 'package:lmb_skripsi/components/text_button.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/firestore_service.dart';
import 'package:lmb_skripsi/helpers/logic/loan_calculator.dart';
import 'package:lmb_skripsi/helpers/logic/sbstorage_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/model/lmb_loan.dart';
import 'package:lmb_skripsi/model/lmb_product.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_mandatory_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_principal_saving.dart';
import 'package:lmb_skripsi/model/lmb_saving/lmb_voluntary_saving.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';
import 'package:lmb_skripsi/pages/main/children/home/children/loan_detail_page.dart';
import 'package:lmb_skripsi/pages/main/children/home/children/product_list_page.dart';
import 'package:lmb_skripsi/pages/main/main_page.dart';

class Homepage extends StatefulWidget {
  static final GlobalKey<_HomepageState> homepageKey = GlobalKey<_HomepageState>();
  Homepage({Key? key}) : super(key: homepageKey);

  static void refresh() {
    homepageKey.currentState?.refresh();
  }

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with AutomaticKeepAliveClientMixin {
  bool showTotalSaving = false;
  List<LmbProduct> productList = [];
  List<LmbLoan> loanList = [];
  late LmbMandatorySaving mandatorySaving;
  late LmbPrincipalSaving principalSaving;
  late LmbVoluntarySaving voluntarySaving;
  double totalSaving = 0;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchAllInitialData();
  }

  void refresh() {
    fetchLoanList();
    fetchSaving();
  }

  Future<void> fetchAllInitialData() async {
    await loadTotalSavingVisibility();
    await fetchProductList();
    await fetchLoanList();
    await fetchSaving();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadTotalSavingVisibility() async {
    final visible = await LmbLocalStorage.getValue<bool>("show_total_saving") ?? false;
    setState(() {
      showTotalSaving = visible;
    });
  }

  Future<void> fetchProductList() async {
    final products = await FirestoreService.instance.getProductList(limit: 5);
    setState(() {
      productList = products;
    });
  }

  Future<void> fetchLoanList() async {
    final loans = await FirestoreService.instance.getLoanList(limit: 5);
    setState(() {
      loanList = loans;
    });
  }

  Future<void> fetchSaving() async {
    final userData = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
    if (userData == null) return;

    final fetchedMandatorySaving = await FirestoreService.instance.getMandatorySaving(userData.nik);
    final fetchedPrincipalSaving = await FirestoreService.instance.getPrincipalSaving(userData.nik);
    final fetchedVoluntarySaving = await FirestoreService.instance.getVoluntarySaving(userData.nik);

    setState(() {
      mandatorySaving = fetchedMandatorySaving;
      principalSaving = fetchedPrincipalSaving;
      voluntarySaving = fetchedVoluntarySaving;
      totalSaving = fetchedMandatorySaving.totalAmount + fetchedPrincipalSaving.totalAmount + fetchedVoluntarySaving.totalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: LmbColors.brand,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // NOTE: Header
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                spacing: 4,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(50),
                      child: SvgPicture.asset(
                        "assets/logo_white.svg",
                        width: 50,
                        height: 50,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white
                        ),
                      ),
                      Text(
                        "Koperasi Lumbung Makmur",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // NOTE: Body
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24)
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NOTE: User card
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: StreamBuilder(
                            stream: AuthenticatorService.instance.userDataStream, 
                            builder: (context, snapshot) {
                              final user = snapshot.data;
                              final profilePictureUrl = user != null
                                ? SbStorageService.instance.getPublicUrl('${user.nik}.jpg', "profile-pictures")
                                : null;

                              return LmbCard(
                                isFullWidth: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // NOTE: User name
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadiusGeometry.circular(8),
                                          child: Container(
                                            color: LmbColors.brand,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              child: Row(
                                                spacing: 8,
                                                children: [
                                                  LmbProfilePicture(
                                                    networkUrl: profilePictureUrl,
                                                    radius: 20
                                                  ),
                                                  Text(
                                                    snapshot.data?.name ?? "Unknown User",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 18,
                                                      color: Colors.white
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),

                                    // NOTE: NIK
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: 140,
                                            child: Text(
                                            "NIK",
                                            style: Theme.of(context).textTheme.labelLarge,
                                          ),
                                        ),
                                        Text(
                                          ": ${snapshot.data?.nik ?? "-"}",
                                          style: Theme.of(context).textTheme.labelMedium,
                                        ),
                                      ],
                                    ),

                                    // NOTE: Total Saving
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                                width: 140,
                                                child: Text(
                                                "Total Savings",
                                                style: Theme.of(context).textTheme.labelLarge,
                                              ),
                                            ),
                                            Text(
                                              showTotalSaving ? ": ${ValueFormatter.formatPriceIDR(totalSaving)}" : ": ••••••",
                                              style: Theme.of(context).textTheme.labelMedium,
                                            ),
                                          ]
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            showTotalSaving ? Icons.visibility : Icons.visibility_off,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            setState(() => showTotalSaving = !showTotalSaving);
                                            await LmbLocalStorage.setValue<bool>("show_total_saving", showTotalSaving);
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    
                                    // NOTE: Member Since
                                    Text(
                                      'Member since: ${DateFormat('dd/MM/yyyy').format(snapshot.data?.createdAt ?? DateTime.now())}',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),

                        // NOTE: Saving scrollable
                        Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(16, 8, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Savings',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              LmbTextButton(
                                text: "More", 
                                color: Theme.of(context).textTheme.bodyLarge?.color ?? LmbColors.brand,
                                size: 18,
                                suffixIcon: Icons.arrow_forward_ios_rounded,
                                onTap: () {
                                  MainPage.setTabIndex(1);
                                }
                              )
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                LmbCard(
                                  child: SizedBox(
                                    width: 150,
                                    child: Column(
                                      spacing: 8,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Mandatory Savings",
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        Text(
                                          ValueFormatter.formatPriceIDR(mandatorySaving.totalAmount),
                                          style: Theme.of(context).textTheme.labelMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                LmbCard(
                                  child: SizedBox(
                                    width: 150,
                                    child: Column(
                                      spacing: 8,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Principal Savings",
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        Text(
                                          ValueFormatter.formatPriceIDR(principalSaving.totalAmount),
                                          style: Theme.of(context).textTheme.labelMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                LmbCard(
                                  child: SizedBox(
                                    width: 150,
                                    child: Column(
                                      spacing: 8,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Voluntary Savings",
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        Text(
                                          ValueFormatter.formatPriceIDR(voluntarySaving.totalAmount),
                                          style: Theme.of(context).textTheme.labelMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),

                        // NOTE: Product scrollable
                        Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(16, 24, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Products',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              LmbTextButton(
                                text: "More", 
                                color: Theme.of(context).textTheme.bodyLarge?.color ?? LmbColors.brand,
                                size: 18,
                                suffixIcon: Icons.arrow_forward_ios_rounded,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProductPage()),
                                  );
                                }
                              )
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: productList.map((product) {
                                final thumbnailUrl = SbStorageService.instance.getPublicUrl("${product.id}.png", "product-thumbnail");
                                return LmbCard(
                                  usePadding: false,
                                  child: Container(
                                    width: 180,
                                    padding: EdgeInsetsGeometry.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadiusGeometry.circular(4),
                                          child: 
                                          Image(
                                            image: NetworkImage(thumbnailUrl!),
                                            alignment: Alignment.center,
                                            fit: BoxFit.contain,
                                            width: 180,
                                            height: 80,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/broken_product.png',
                                                alignment: Alignment.center,
                                                fit: BoxFit.contain,
                                                width: 180,
                                                height: 80,
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          product.name,
                                          style: Theme.of(context).textTheme.labelMedium,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          ValueFormatter.formatPriceIDR(product.price),
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                      ],
                                    ),
                                  )
                                );
                              }).toList(),
                            ),
                          )
                        ),

                        // NOTE: Loan scrollable
                        Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'Active Loans',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                          child: Column(
                            spacing: 16,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: loanList.map((loan) {
                              final nextDueDate = LoanCalculator.calculateNextPaymentDueDate(loan);
                              final formattedNextDueDate = nextDueDate != null
                                  ? DateFormat('dd MMM yyyy').format(nextDueDate)
                                  : '-';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoanDetailPage(model: loan)),
                                  );
                                },
                                child: LmbCard(
                                  isFullWidth: true,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Loan Amount",
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                      Text(
                                        ValueFormatter.formatPriceIDR(loan.loanAmount),
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 16),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Remaining",
                                                style: Theme.of(context).textTheme.labelMedium,
                                              ),
                                              Text(
                                                "${LoanCalculator.calculateRemainingMonths(loan)} month(s)",
                                                style: Theme.of(context).textTheme.bodyLarge,
                                              ),
                                            ],
                                          ),

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Next Due",
                                                style: Theme.of(context).textTheme.labelMedium,
                                              ),
                                              Text(
                                                formattedNextDueDate,
                                                style: Theme.of(context).textTheme.bodyLarge,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding: EdgeInsetsGeometry.symmetric(vertical: 4),
                                        child: Divider(
                                          color: Theme.of(context).textTheme.bodyMedium?.color ?? LmbColors.darkTextLow,
                                        ),
                                      ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Monthly Installment",
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ),
                                          Text(
                                            ValueFormatter.formatPriceIDR(
                                              LoanCalculator.calculateMonthlyInstallment(loan),
                                            ),
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                        ]
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        if (loanList.isEmpty) SizedBox(
                          height: 80,
                          child: Center(
                            child: Text("You don't have any active loans."),
                          )
                        ),

                        const SizedBox(height: 120)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}