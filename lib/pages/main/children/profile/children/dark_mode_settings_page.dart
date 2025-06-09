import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/helpers/logic/theme_notifier.dart';
import 'package:provider/provider.dart';

class DarkModeSettingsPage extends StatefulWidget {
  const DarkModeSettingsPage({super.key});

  @override
  State<DarkModeSettingsPage> createState() => _DarkModeSettingsPageState();
}

class _DarkModeSettingsPageState extends State<DarkModeSettingsPage> {
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    final themeNotifier = context.read<ThemeNotifier>();
    _selectedTheme = themeNotifier.themeMode;
  }

  void _onThemeChanged(ThemeMode? mode) {
    if (mode != null) {
      setState(() {
        _selectedTheme = mode;
      });
      context.read<ThemeNotifier>().setThemeMode(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      title: "Dark Mode",
      children: [
        RadioListTile<ThemeMode>(
          title: const Text("System Default"),
          value: ThemeMode.system,
          groupValue: _selectedTheme,
          onChanged: _onThemeChanged,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Light Mode"),
          value: ThemeMode.light,
          groupValue: _selectedTheme,
          onChanged: _onThemeChanged,
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Dark Mode"),
          value: ThemeMode.dark,
          groupValue: _selectedTheme,
          onChanged: _onThemeChanged,
        ),
      ],
    );
  }
}