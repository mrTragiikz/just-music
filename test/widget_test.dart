import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_app/providers/settings_provider.dart';
import 'package:my_app/screens/splash/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders app title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: const MaterialApp(home: SplashScreen()),
      ),
    );

    expect(find.text('OFFLINE MUSIC PLAYER'), findsOneWidget);
    expect(find.text('By Prabin Sharma'), findsOneWidget);

    // Unmount before the navigation timer fires; dispose() must cancel it
    // cleanly so no pending timer is left for the test framework to flag.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
