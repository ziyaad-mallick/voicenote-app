import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._();
  SettingsService._();

  late Box _box;

  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyApiKey = 'apiKey';
  static const String _keyCategories = 'categories';
  static const String _keyOnboarded = 'onboarded';
  static const String _keyThemeModeName = 'themeModeName';

  Future<void> init() async {
    _box = await Hive.openBox('settings');
  }

  String get userName => _box.get(_keyUserName, defaultValue: '') as String;
  set userName(String value) => _box.put(_keyUserName, value);

  String get userEmail => _box.get(_keyUserEmail, defaultValue: '') as String;
  set userEmail(String value) => _box.put(_keyUserEmail, value);

  String get apiKey => _box.get(_keyApiKey, defaultValue: '') as String;
  set apiKey(String value) => _box.put(_keyApiKey, value);

  List<String> get categories {
    final stored = _box.get(_keyCategories, defaultValue: null);
    if (stored == null) {
      return ['Projects', 'Ideas', 'Uni', 'Personal'];
    }
    return List<String>.from(stored as List);
  }
  set categories(List<String> value) => _box.put(_keyCategories, value);

  bool get onboarded => _box.get(_keyOnboarded, defaultValue: false) as bool;
  set onboarded(bool value) => _box.put(_keyOnboarded, value);

  String get themeModeName => _box.get(_keyThemeModeName, defaultValue: 'system') as String;
  set themeModeName(String value) => _box.put(_keyThemeModeName, value);
}
