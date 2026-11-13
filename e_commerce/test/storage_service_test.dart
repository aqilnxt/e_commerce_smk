import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_commerce/app/data/local/storage_service.dart';

void main() {
  testWidgets('tema dibaca dari disk dan disimpan lagi saat diganti', (tester) async {
    SharedPreferences.setMockInitialValues({'is_dark_mode': true});
    final storage = await StorageService().init(initHive: false);
    expect(storage.themeMode, ThemeMode.dark);

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    await storage.toggleTheme();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(storage.themeMode, ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('is_dark_mode'), isFalse);
    expect(find.text('Mode Terang Diaktifkan'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
