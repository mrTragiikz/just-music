import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/audio_handler.dart';
import 'providers/library_provider.dart';
import 'providers/player_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash/splash_screen.dart';

late MusicAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.prabinsharma.offlinemusicplayer.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settingsProvider),
      ChangeNotifierProvider(create: (_) => PlayerProvider(audioHandler)),
      ChangeNotifierProvider(create: (_) => LibraryProvider()..init()),
      ChangeNotifierProvider(create: (_) => PlaylistProvider()..load()),
    ],
    child: const OfflineMusicPlayerApp(),
  ));
}

class OfflineMusicPlayerApp extends StatelessWidget {
  const OfflineMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Just Music',
      debugShowCheckedModeBanner: false,
      themeMode: settings.materialThemeMode,
      theme: settings.themeMode == AppThemeMode.light
          ? AppTheme.light(settings.accentColor, null)
          : settings.themeMode == AppThemeMode.amoled
              ? AppTheme.amoled(settings.accentColor, null)
              : AppTheme.dark(settings.accentColor, null),
      darkTheme: settings.themeMode == AppThemeMode.amoled
          ? AppTheme.amoled(settings.accentColor, null)
          : AppTheme.dark(settings.accentColor, null),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontScale),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
