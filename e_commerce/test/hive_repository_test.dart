import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'package:e_commerce/app/core/network/dio_exception.dart';
import 'package:e_commerce/app/core/network/result.dart';
import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/data/remote/product_remote_datasource.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';

class FakeRemote implements ProductRemoteDataSource {
  bool online = true;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    if (!online) throw const NetworkFailure(code: -6, message: 'offline');
    return const [
      ProductModel(
        id: '1',
        name: 'Sepatu A',
        category: 'Mens-shoes',
        price: 1000000,
        rating: 4.5,
        imageUrl: '',
      ),
    ];
  }
}

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductModelAdapter());
    await Hive.openBox<ProductModel>(ProductLocalDataSourceImpl.productsBoxName);
    await Hive.openBox<ProductModel>(ProductLocalDataSourceImpl.wishlistBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('katalog disimpan ke Hive lalu dipakai saat offline', () async {
    final remote = FakeRemote();
    final repo = ProductRepositoryImpl(remote, ProductLocalDataSourceImpl());

    expect(await repo.fetchProducts(), isA<Success<List<ProductModel>, String>>());

    remote.online = false;
    final offline = await repo.fetchProducts();
    expect(offline, isA<Success<List<ProductModel>, String>>());
    expect((offline as Success<List<ProductModel>, String>).data.single.name, 'Sepatu A');
  });

  test('offline tanpa cache menghasilkan Failure', () async {
    final repo = ProductRepositoryImpl(FakeRemote()..online = false, ProductLocalDataSourceImpl());
    expect(await repo.fetchProducts(), isA<Failure<List<ProductModel>, String>>());
  });

  test('wishlist bertahan setelah box ditutup dan dibuka lagi', () async {
    final repo = ProductRepositoryImpl(FakeRemote(), ProductLocalDataSourceImpl());
    const product = ProductModel(
      id: '9',
      name: 'Favorit',
      category: 'C',
      price: 1,
      rating: 5,
      imageUrl: '',
    );

    expect(await repo.toggleWishlist(product), isTrue);
    await Hive.box<ProductModel>(ProductLocalDataSourceImpl.wishlistBoxName).close();
    await Hive.openBox<ProductModel>(ProductLocalDataSourceImpl.wishlistBoxName);

    expect(repo.isFavorite('9'), isTrue);
    expect(repo.getWishlist().single.isFavorite, isTrue);
    expect(await repo.toggleWishlist(product), isFalse);
    expect(repo.getWishlist(), isEmpty);
  });
}
