import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _modeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.amoled:
        return 'AMOLED Black';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('General'),
          SwitchListTile(
            title: const Text('Auto Scan Music'),
            subtitle: const Text('Automatically scan device for new songs'),
            value: settings.autoScan,
            onChanged: settings.setAutoScan,
          ),
          ListTile(
            title: const Text('Rescan Library'),
            subtitle: Text('${library.songs.length} songs found'),
            trailing: const Icon(Icons.refresh),
            onTap: library.scanLibrary,
          ),
          const Divider(),
          const _SectionHeader('Appearance'),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_modeLabel(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeSheet(context, settings),
          ),
          ListTile(
            title: const Text('Accent Color'),
            subtitle: Text(settings.accentColor.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAccentSheet(context, settings),
          ),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Slider(
              value: settings.fontScale,
              min: 0.85,
              max: 1.3,
              divisions: 9,
              label: settings.fontScale.toStringAsFixed(2),
              onChanged: settings.setFontScale,
            ),
          ),
          const Divider(),
          const _SectionHeader('About'),
          ListTile(
            title: const Text('Just Music'),
            subtitle: const Text('Developed by Prabin Sharma'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutSheet(context),
          ),
          const ListTile(
            title: Text('No Ads · No Login · No Premium · 100% Offline'),
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values
              .map((mode) => RadioListTile<AppThemeMode>(
                    title: Text(_modeLabel(mode)),
                    value: mode,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) settings.setThemeMode(value);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Just Music',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This app is built by Prabin Sharma to ensure users are free '
                'from ads and unwanted logins. Enjoy, dear!',
              ),
              const SizedBox(height: 20),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.email_outlined),
                title: Text('sharmaprabin160@gmail.com'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.phone_outlined),
                title: Text('9761734136'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccentSheet(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AccentColor.values
              .map((color) => RadioListTile<AccentColor>(
                    title: Text(color.label),
                    secondary: CircleAvatar(backgroundColor: color.seed, radius: 12),
                    value: color,
                    groupValue: settings.accentColor,
                    onChanged: (value) {
                      if (value != null) settings.setAccentColor(value);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
