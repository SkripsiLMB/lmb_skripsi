import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/navigation_bar.dart';
import 'package:lmb_skripsi/pages/main/children/home_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homepage(),
    SavingsPage(),
    LoanPage(),
    ProfilePage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.only(bottom: 90),
        child: _pages[_selectedIndex],
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

class SavingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Savings Page', style: TextStyle(fontSize: 24)));
}

class LoanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Loan Page', style: TextStyle(fontSize: 24)));
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Profile Page', style: TextStyle(fontSize: 24)));
}