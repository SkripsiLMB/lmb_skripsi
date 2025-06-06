import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lmb_skripsi/components/card.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/model/lmb_user.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  LmbUser? userData;
  bool showSHU = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadSHUVisibility();
  }

  Future<void> loadUserData() async {
    final data = await LmbLocalStorage.getValue<LmbUser>("user_data", fromJson: (json) => LmbUser.fromJson(json));
    setState(() {
      userData = data as LmbUser;
    });
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
                        "Welcome,",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white
                        ),
                      ),
                      Text(
                        userData?.name ?? "Unknown User",
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
                      child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NOTE: User card
                          LmbCard(
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
                                            spacing: 6,
                                            children: [
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadiusGeometry.circular(40),
                                                  child: Image.asset(
                                                    "assets/app_icon.png",
                                                    width: 40,
                                                    height: 40,
                                                    scale: 1,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                userData?.name ?? "Unknown User",
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
                                        width: 120,
                                        child: Text(
                                        "NIK",
                                        style: Theme.of(context).textTheme.labelLarge,
                                      ),
                                    ),
                                    Text(
                                      ": ${userData?.nik ?? "-"}",
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ],
                                ),

                                // NOTE: Total SHU
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: 120,
                                            child: Text(
                                            "Total SHU",
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
                                  'Member since: ${DateFormat('dd/MM/yyyy').format(userData?.createdAt ?? DateTime.now())}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
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