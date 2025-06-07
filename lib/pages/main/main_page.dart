// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/navigation_bar.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/pages/main/children/home/home_page.dart';
import 'package:lmb_skripsi/pages/main/children/loan/loan_page.dart';
import 'package:lmb_skripsi/pages/main/children/profile/profile_page.dart';
import 'package:lmb_skripsi/pages/main/children/saving/saving_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homepage(),
    SavingPage(),
    LoanPage(),
    ProfilePage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await AuthenticatorService.instance.initializeUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      resizeToAvoidBottomInset: true,
      extendBody: true,
      bottomNavigationBar: LmbBottomNavBar(
        currentIndex: _selectedIndex,
        onItemSelected: _onTabSelected,
      ),
    );
  }
}