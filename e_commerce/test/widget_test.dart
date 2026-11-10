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
    expect(find.text('3'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Keranjang Belanja (3)'), findsOneWidget);
    expect(find.text('Rp 7.497.000'), findsNWidgets(2));
    expect(find.text('Rp 824.670'), findsOneWidget);
    expect(find.text('Gratis'), findsOneWidget);
    expect(find.text('Rp 8.321.670'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text('Keranjang Belanja (4)'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus').last);
    await tester.pumpAndSettle();
    expect(find.text('Keranjang masih kosong'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_border_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('Wishlist Favorit'), findsOneWidget);
    await tester.tap(find.text('Ke Keranjang'));
    await settle(tester);
    expect(find.text('Belum ada produk favorit'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    FlutterError.onError = reportError;
  });
}
