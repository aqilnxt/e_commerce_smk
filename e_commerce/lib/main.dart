import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/theme/app_theme.dart';
import 'app/data/local/storage_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  // Engine Flutter harus siap sebelum SharedPreferences dan Hive diakses
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await Get.putAsync(() => StorageService().init());

  runApp(
    GetMaterialApp(
      title: "KicksStore",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storageService.themeMode,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
