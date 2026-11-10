import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:e_commerce/app/routes/app_pages.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  setUp(Get.reset);

  testWidgets('filter, favorit, badge, dan stepper reaktif', (tester) async {
    tester.view.physicalSize = const Size(2700, 6000); // font tes (Ahem) jauh lebih lebar dari font asli
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Semua request gambar di flutter_test selalu dibalas 400
    final reportError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is! NetworkImageLoadException) reportError!(details);
    };

    await tester.pumpWidget(
      GetMaterialApp(initialRoute: AppPages.INITIAL, getPages: AppPages.routes),
    );
    await tester.pumpAndSettle();
    expect(find.text('6 Produk'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Basketball'));
    await tester.pump();
    expect(find.text('1 Produk'), findsOneWidget);
    expect(find.text('Rp 2.499.000'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pump();
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_shopping_cart_rounded));
    await settle(tester);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Nike Air Jordan 1 Retro High'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byIcon(Icons.add_rounded));
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Tambah ke Keranjang'));
    await settle(tester);

    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    FlutterError.onError = reportError;
  });
}
