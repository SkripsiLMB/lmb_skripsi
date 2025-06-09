import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/product_card.dart';
import 'package:lmb_skripsi/components/profile_picture.dart';
import 'package:lmb_skripsi/components/text_button.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/sbstorage_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/pages/main/children/home/children/product_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool showSHU = false;

  @override
  void initState() {
    super.initState();
    loadSHUVisibility();
  }

  Future<void> loadSHUVisibility() async {
    final visible = await LmbLocalStorage.getValue<bool>("show_shu") ?? false;
    setState(() {
      showSHU = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                              showSHU ? ": Rp0" : ": ••••••",
                                              style: Theme.of(context).textTheme.labelMedium,
                                            ),
                                          ]
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            showSHU ? Icons.visibility : Icons.visibility_off,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            setState(() => showSHU = !showSHU);
                                            await LmbLocalStorage.setValue<bool>("show_shu", showSHU);
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
                          padding: EdgeInsetsGeometry.fromLTRB(16, 0, 16, 8),
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
                                  child: SizedBox(width: 100, height: 60),
                                ),
                                LmbCard(
                                  child: SizedBox(width: 100, height: 60),
                                ),
                                LmbCard(
                                  child: SizedBox(width: 100, height: 60),
                                ),
                                LmbCard(
                                  child: SizedBox(width: 100, height: 60),
                                ),
                                LmbCard(
                                  child: SizedBox(width: 100, height: 60),
                                ),
                                LmbCard(
                                  child: SizedBox(width: 100, height: 60),
                                ),
                                LmbCard(
                                  child: SizedBox(width: 100, height: 60),
                                ),
                              ],
                            ),
                          )
                        ),

                        // NOTE: Product scrollable
                        Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Product',
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
                              children: [
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                              ],
                            ),
                          )
                        ),

                        // NOTE: Loan scrollable
                        Padding(
                          padding: EdgeInsetsGeometry.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Loans',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              LmbTextButton(
                                text: "More", 
                                color: Theme.of(context).textTheme.bodyLarge?.color ?? LmbColors.brand,
                                size: 18,
                                suffixIcon: Icons.arrow_forward_ios_rounded,
                                onTap: () {
                                  
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
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                                ProductCard(
                                  name: "Chitato", 
                                  price: 12000
                                ),
                              ],
                            ),
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