import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_commerce/app/core/network/result.dart';
import 'package:e_commerce/app/core/services/auth_service.dart';
import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';
import 'package:e_commerce/app/routes/app_pages.dart';

import 'cart_controller_test.dart' show MemoryCartDataSource;

/// Repository palsu supaya test tidak bergantung pada internet
class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this.result);

  final Result<List<ProductModel>, String> result;

  final _wishlist = <String, ProductModel>{};

  @override
  Future<Result<List<ProductModel>, String>> fetchProducts() async => result;

  @override
  List<ProductModel> getWishlist() => _wishlist.values.toList();

  @override
  bool isFavorite(String productId) => _wishlist.containsKey(productId);

  @override
  Future<bool> toggleWishlist(ProductModel product) async {
    if (_wishlist.remove(product.id) != null) return false;
    _wishlist[product.id] = product;
    return true;
  }
}

/// Tanpa Firebase.initializeApp, AuthService berjalan dalam mode lokal
Future<AuthService> useRepository(Result<List<ProductModel>, String> result) async {
  Get.put<ProductRepository>(FakeProductRepository(result), permanent: true);
  Get.put<CartLocalDataSource>(MemoryCartDataSource(), permanent: true);
  SharedPreferences.setMockInitialValues({});
  return Get.put<AuthService>(await AuthService().init(), permanent: true);
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  setUp(Get.reset);

  testWidgets('filter, favorit, badge, dan stepper reaktif', (tester) async {
    // Server gagal -> katalog lokal cadangan (6 produk) yang tampil
    await useRepository(const Failure('offline'));
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
    expect(find.text('Wishlist Favorit (1)'), findsOneWidget);
    await tester.tap(find.text('Ke Keranjang'));
    await settle(tester);
    expect(find.text('Belum Ada Sepatu Favorit'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    FlutterError.onError = reportError;
  });

  testWidgets('form login menampilkan error validasi secara realtime', (tester) async {
    await useRepository(const Failure('offline'));
    tester.view.physicalSize = const Size(2700, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(initialRoute: Routes.LOGIN, getPages: AppPages.routes),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pump();
    expect(find.text('Alamat email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'siswa@sekolah.sch.id');
    await tester.enterText(find.byType(TextFormField).last, 'sepatubaru');
    await tester.pump();
    expect(find.text('Alamat email wajib diisi'), findsNothing);
    expect(find.text('Kata sandi harus mengandung minimal 1 angka (0-9)'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'sepatubaru1');
    await tester.pump();
    expect(find.text('Kata sandi harus mengandung minimal 1 angka (0-9)'), findsNothing);

    final field = () => tester.widget<EditableText>(find.byType(EditableText).last);
    expect(field().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(field().obscureText, isFalse);

    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Katalog Sneakers'), findsOneWidget);
  });

  testWidgets('data server tampil dan snackbar sukses muncul', (tester) async {
    tester.view.physicalSize = const Size(2700, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await useRepository(Success([
      ProductModel.fromJson({'id': 1, 'title': 'Sepatu A', 'category': 'mens-shoes', 'price': 100}),
      ProductModel.fromJson({'id': 2, 'title': 'Sepatu B', 'category': 'mens-shoes', 'price': 50}),
    ]));

    final reportError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is! NetworkImageLoadException) reportError!(details);
    };

    await tester.pumpWidget(
      GetMaterialApp(initialRoute: AppPages.INITIAL, getPages: AppPages.routes),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Katalog Berhasil Diperbarui'), findsOneWidget);
    expect(find.text('Berhasil mengunduh 2 sepatu terbaru dari server!'), findsOneWidget);
    expect(find.text('2 Produk'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Mens-shoes'), findsOneWidget);
    expect(find.text('Rp 1.500.000'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    FlutterError.onError = reportError;
  });

  testWidgets('tamu dicegat ke login lalu dikembalikan ke checkout', (tester) async {
    tester.view.physicalSize = const Size(2700, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final auth = await useRepository(const Failure('offline'));

    await tester.pumpWidget(
      GetMaterialApp(initialRoute: AppPages.INITIAL, getPages: AppPages.routes),
    );
    await tester.pumpAndSettle();

    Get.toNamed(Routes.CHECKOUT);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Akses Dibatasi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(auth.redirectRoute, Routes.CHECKOUT);

    await tester.enterText(find.byType(TextFormField).first, 'siswa@sekolah.sch.id');
    await tester.enterText(find.byType(TextFormField).last, 'sepatubaru1');
    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Pengiriman & Checkout'), findsOneWidget);
    expect(auth.isLoggedIn.value, isTrue);
    expect(auth.redirectRoute, isNull);

    await tester.tap(find.text('GoSend Instant • Rp 35.000'));
    await tester.pump();
    expect(find.text('Ongkos Kirim (GoSend Instant)'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'smkbisa');
    await tester.tap(find.text('Gunakan Kupon'));
    await tester.pump();
    expect(find.text('Potongan Promo Kupon (SMKBISA)'), findsOneWidget);

    // Snackbar GetX antre satu per satu, tunggu sampai semuanya tertutup
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();
  });
}
