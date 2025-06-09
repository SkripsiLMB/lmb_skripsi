import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/components/menu_list.dart';
import 'package:lmb_skripsi/components/profile_picture.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/remote_config_service.dart';
import 'package:lmb_skripsi/helpers/logic/sbstorage_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/main.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';
import 'package:lmb_skripsi/pages/main/children/profile/children/change_email_page.dart';
import 'package:lmb_skripsi/pages/main/children/profile/children/change_profile_picture_page.dart';
import 'package:lmb_skripsi/pages/main/children/profile/children/change_username_page.dart';
import 'package:lmb_skripsi/pages/main/children/profile/children/dark_mode_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int nikTapCount = 0;
  bool showDeveloperMenu = false;

  @override
  void initState() {
    super.initState();
    _loadDeveloperMenu();
  }

  void _loadDeveloperMenu() async {
    final result = await LmbLocalStorage.getValue<bool>("show_developer_menu");
    if (mounted) {
      setState(() {
        showDeveloperMenu = result ?? false;
      });
    }
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
              child: StreamBuilder(
                stream: AuthenticatorService.instance.userDataStream, 
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final profilePictureUrl = user != null
                    ? SbStorageService.instance.getPublicUrl('${user.nik}.jpg', "profile-pictures")
                    : null;

                  return Row(
                    spacing: 16,
                    children: [
                      LmbProfilePicture(
                        networkUrl: profilePictureUrl,
                        radius: 35
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data?.name ?? "Unknown User",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          GestureDetector(
                            onTap: () {
                              nikTapCount++;
                              if (nikTapCount >= 8) {
                                nikTapCount = 0;
                                WindowProvider.showDialogBox(
                                  context: context, 
                                  title: "Developer Menu", 
                                  description: "Do you want to ${showDeveloperMenu ? "disable" : "enable"} developer menu?", 
                                  isBarrierDismissable: false,
                                  primaryText: showDeveloperMenu ? "Disable" : "Enable", 
                                  onPrimary: () async {
                                     await LmbLocalStorage.setValue<bool>("show_developer_menu", !showDeveloperMenu);
                                    setState(() {
                                      showDeveloperMenu = !showDeveloperMenu;
                                    });
                                    WindowProvider.toastInfo(context, "Developer menu ${showDeveloperMenu ? "enabled" : "disabled"}");
                                  },
                                  secondaryText: "Cancel"
                                );
                              }
                            },
                            child: Text(
                              "NIK: ${snapshot.data?.nik ?? "-"}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              )
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
                            isFullWidth: true,
                            usePadding: false,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 6,
                              children: [
                                MenuList(
                                  icon: Icons.photo_rounded,
                                  title: "Change Profile Picture",
                                  description: "Make changes to your profile picture",
                                  isFirstItem: true,
                                  onTap: () {
                                    final userNik = AuthenticatorService.instance.userData?.nik;
                                    if (userNik != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChangeProfilePicturePage(nik: userNik),
                                        ),
                                      );
                                    } else {
                                      WindowProvider.toastError(context, "Something went wrong.");
                                    }
                                  },
                                ),
                                MenuList(
                                  icon: Icons.chrome_reader_mode_rounded,
                                  title: "Change Username",
                                  description: "Make changes to your username",
                                  onTap: () {
                                    final userName = AuthenticatorService.instance.userData?.name;
                                    if (userName != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChangeUsernamePage(currentName: userName),
                                        ),
                                      );
                                    } else {
                                      WindowProvider.toastError(context, "Something went wrong.");
                                    }
                                  },
                                ),
                                MenuList(
                                  icon: Icons.email_rounded,
                                  title: "Change Profile Email",
                                  description: "Make changes to your email",
                                  onTap: () {
                                    final userEmail = AuthenticatorService.instance.userData?.email;
                                    if (userEmail != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChangeEmailPage(currentEmail: userEmail),
                                        ),
                                      );
                                    } else {
                                      WindowProvider.toastError(context, "Something went wrong.");
                                    }
                                  },
                                ),
                                MenuList(
                                  icon: Icons.lock_person_rounded,
                                  title: "Change Password",
                                  description: "Make changes to your password",
                                  onTap: () {
                                    WindowProvider.showDialogBox(
                                      context: context, 
                                      title: "Change Password Confirmation", 
                                      description: "Are you sure you want to change your password? We will send a password reset link to your current email.", 
                                      primaryText: "Change Password", 
                                      onPrimary: () async {
                                        final userData = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
                                        final userEmail = userData?.email;
                                        if (userEmail != null) {
                                          if (await AuthenticatorService.instance.handleForgotPassword(context, userEmail)) {
                                            WindowProvider.toastSuccess(context, 'Check your email inbox');
                                          }
                                        } else {
                                          WindowProvider.toastError(context, 'Something went wrong');
                                        }
                                      }, 
                                      secondaryText: "Cancel",
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
                                      title: "Sign Out Confirmation", 
                                      description: "Are you sure you want to sign out from your account?", 
                                      primaryText: "Sign out", 
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
                            isFullWidth: true,
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

                          // NOTE: Developer menu
                          if (showDeveloperMenu) ...[
                            Text(
                              "Developer",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            LmbCard(
                              isFullWidth: true,
                              usePadding: false,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 6,
                                children: [
                                  MenuList(
                                    icon: Icons.restart_alt_rounded,
                                    isFirstItem: true,
                                    title: "Restart Application",
                                    description: "Restart application without killing it",
                                    onTap: () async {
                                      RestartWidget.restartApp(context);
                                      WindowProvider.toastSuccess(context, "Successfully restarted app widget.");
                                    },
                                  ),
                                  MenuList(
                                    icon: Icons.settings_applications_rounded,
                                    title: "Fetch remote config",
                                    description: "Refetch remote config from Firebase",
                                    onTap: () async {
                                      await RemoteConfigService.instance.forceRefetch();
                                      WindowProvider.toastSuccess(context, "Successfully fetched remote config.");
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 120)
                          ],
                        ],
                      ),
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