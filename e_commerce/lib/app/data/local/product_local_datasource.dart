import 'package:hive_ce/hive.dart';

import 'package:e_commerce/app/data/models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  List<ProductModel> getCachedProducts();
  List<ProductModel> getWishlist();
  bool isInWishlist(String productId);
  Future<void> saveToWishlist(ProductModel product);
  Future<void> removeFromWishlist(String productId);
}

/// Akses box Hive CE untuk katalog offline dan wishlist favorit.
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String productsBoxName = 'products_box';
  static const String wishlistBoxName = 'wishlist_box';

  Box<ProductModel> get _productsBox => Hive.box<ProductModel>(productsBoxName);
  Box<ProductModel> get _wishlistBox => Hive.box<ProductModel>(wishlistBoxName);

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final Map<String, ProductModel> map = {for (final p in products) p.id: p};
    await _productsBox.putAll(map);
  }

  @override
  List<ProductModel> getCachedProducts() => _productsBox.values.toList();

  @override
  List<ProductModel> getWishlist() => _wishlistBox.values.toList();

  @override
  bool isInWishlist(String productId) => _wishlistBox.containsKey(productId);

  @override
  Future<void> saveToWishlist(ProductModel product) async {
    await _wishlistBox.put(product.id, product.copyWith(isFavorite: true));
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    await _wishlistBox.delete(productId);
  }
}
