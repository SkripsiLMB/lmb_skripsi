import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/menu_list.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';
import 'package:lmb_skripsi/pages/main/children/profile/children/account_settings_page.dart';
import 'package:lmb_skripsi/pages/main/children/profile/children/dark_mode_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  LmbUser? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
    setState(() {
      userData = data as LmbUser;
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
                spacing: 12,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(50),
                      child: Image.asset(
                        "assets/app_icon.png",
                        width: 50,
                        height: 50,
                        scale: 1,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData?.name ?? "Unknown User",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "NIK: ${userData?.nik ?? "-"}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white
                        ),
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
                      child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          // NOTE: Account
                          Text(
                            "Account",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          LmbCard(
                            usePadding: false,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 6,
                              children: [
                                MenuList(
                                  icon: Icons.person_rounded,
                                  title: "My Account",
                                  description: "Make changes to your account",
                                  isFirstItem: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
                                    );
                                  },
                                ),
                                MenuList(
                                  icon: Icons.logout_rounded,
                                  title: "Sign Out",
                                  description: "Sign out from your account",
                                  color: LmbColors.error,
                                  onTap: () {
                                    WindowProvider.showDialogBox(
                                      context: context, 
                                      title: "Logout Confirmation", 
                                      description: "Are you sure you want to logout from your account?", 
                                      primaryText: "Logout", 
                                      onPrimary: () {
                                        AuthenticatorService.instance.handleLogout();
                                      }, 
                                      secondaryText: "Cancel",
                                      customColor: LmbColors.error
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 16),

                          // NOTE: Accessibility
                          Text(
                            "Accessibility",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          LmbCard(
                            usePadding: false,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 6,
                              children: [
                                MenuList(
                                  icon: Icons.dark_mode_rounded,
                                  title: "Dark Mode",
                                  description: "Configure your application theme",
                                  isFirstItem: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const DarkModeSettingsPage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}