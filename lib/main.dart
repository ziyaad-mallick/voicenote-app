import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/app_theme.dart';
import 'services/settings_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

/// Drives live theme switching from Settings.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);

ThemeMode themeModeFromName(String name) {
  switch (name) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

void applyThemeFromSettings() {
  themeModeNotifier.value =
      themeModeFromName(SettingsService.instance.themeModeName);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await SettingsService.instance.init();
  await StorageService.instance.init();
  await NotificationService.instance.init();

  applyThemeFromSettings();

  runApp(const VoiceNoteApp());
}

class VoiceNoteApp extends StatelessWidget {
  const VoiceNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarded = SettingsService.instance.onboarded;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'VoiceNote',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: onboarded ? const HomeScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}
