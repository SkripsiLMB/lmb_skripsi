import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LmbLocalStorage {
  static Future<void> setValue<T>(String key, T value, {Map<String, dynamic> Function(T)? toJson}) async {
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
    } else if (toJson != null) {
      final jsonString = jsonEncode(toJson(value));
      await prefs.setString(key, jsonString);
    } else {
      throw Exception("No serializer provided for type ${T.runtimeType}");
    }
  }

  static Future<T?> getValue<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) async {
    final prefs = await SharedPreferences.getInstance();
    if (T == bool) return prefs.getBool(key) as T?;
    if (T == int) return prefs.getInt(key) as T?;
    if (T == double) return prefs.getDouble(key) as T?;
    if (T == String) return prefs.getString(key) as T?;
    if (T == List<String>) return prefs.getStringList(key) as T?;
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    if (fromJson != null) {
      final jsonMap = jsonDecode(jsonString);
      return fromJson(jsonMap as Map<String, dynamic>);
    } else {
      throw Exception("No deserializer provided for type ${T.runtimeType}");
    }
  }

  static Future<void> deleteValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clearAllValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}