import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LmbLocalStorage {
  static Future<void> setValue<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value == null) {
      await prefs.remove(key);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      String jsonString = jsonEncode(value);
      await prefs.setString(key, jsonString);
    }
  }

  static Future<T?> getValue<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();

    if (T == bool) {
      return prefs.getBool(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == List<String>) {
      return prefs.getStringList(key) as T?;
    } else {
      String? jsonString = prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as T;
    }
  }
}