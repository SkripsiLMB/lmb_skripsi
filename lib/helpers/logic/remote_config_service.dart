import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  // NOTE: sistem singleton
  static final RemoteConfigService _instance = RemoteConfigService._();
  static RemoteConfigService get instance => _instance;
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // NOTE: variable
  final Map<String, dynamic> _configCache = {};
  RemoteConfigService._();
  final List<String> _configKeys = [
    'loan_interest_config',
    'is_app_disabled_config',
    'amount_config'
  ];

  // NOTE: inisialisasi data awal
  Future<void> initialize({
    Duration fetchTimeout = const Duration(seconds: 0),
    Duration minimumFetchInterval = const Duration(hours: 8),
  }) async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: fetchTimeout,
      minimumFetchInterval: minimumFetchInterval,
    ));

    await fetchAndCacheAll();
  }

  // NOTE: ambil dan masukin semua
  Future<void> fetchAndCacheAll() async {
    await _remoteConfig.fetchAndActivate();

    for (final key in _configKeys) {
      final raw = _remoteConfig.getString(key);
      if (raw.isNotEmpty) {
        try {
          _configCache[key] = json.decode(raw);
        } catch (_) {
          _configCache[key] = raw;
        }
      }
    }
  }

  // NOTE: ambil config
  Future<T> get<T>(String key, T Function(dynamic json) fromJson) async {
    final value = _configCache[key];
    if (value != null) {
      try {
        return fromJson(value);
      } catch (e) {
        throw Exception("Failed to parse config for key '$key': $e");
      }
    }

    throw Exception("Config for key '$key' not found.");
  }

  // NOTE: Force refetch
  Future<void> forceRefetch() async {
    final currentSettings = _remoteConfig.settings;
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await _remoteConfig.fetchAndActivate();
    for (final key in _configKeys) {
      final raw = _remoteConfig.getString(key);
      if (raw.isNotEmpty) {
        try {
          _configCache[key] = json.decode(raw);
        } catch (_) {
          _configCache[key] = raw;
        }
      }
    }
    await _remoteConfig.setConfigSettings(currentSettings);
  }
}