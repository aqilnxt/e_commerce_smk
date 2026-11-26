import 'package:e_commerce/app/core/network/dio_exception.dart';
import 'package:e_commerce/app/core/network/result.dart';
import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/data/remote/product_remote_datasource.dart';

abstract class ProductRepository {
  Future<Result<List<ProductModel>, String>> fetchProducts();
  List<ProductModel> getWishlist();
  Future<bool> toggleWishlist(ProductModel product);
  bool isFavorite(String productId);
}

/// Single Source of Truth: server dulu, simpan ke Hive, dan pakai cache saat offline.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  ProductRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<List<ProductModel>, String>> fetchProducts() async {
    try {
      // 1. Ambil data terbaru dari server REST API
      final remoteProducts = await _remoteDataSource.fetchProducts();

      // 2. Simpan salinan ke dalam cache offline Hive CE
      if (remoteProducts.isNotEmpty) {
        await _localDataSource.cacheProducts(remoteProducts);
      }

      return Success(remoteProducts);
    } on NetworkFailure catch (e) {
      // 3. Fallback Offline: jika server gagal atau offline, ambil dari cache lokal Hive
      final cachedProducts = _localDataSource.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return Success(cachedProducts);
      }
      return Failure(e.message);
    } catch (e) {
      final cachedProducts = _localDataSource.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return Success(cachedProducts);
      }
      return Failure('Gagal memuat katalog produk: ${e.toString()}');
    }
  }

  @override
  List<ProductModel> getWishlist() => _localDataSource.getWishlist();

  @override
  bool isFavorite(String productId) => _localDataSource.isInWishlist(productId);

  /// Mengembalikan true jika produk sekarang masuk wishlist, false jika baru dihapus.
  @override
  Future<bool> toggleWishlist(ProductModel product) async {
    if (_localDataSource.isInWishlist(product.id)) {
      await _localDataSource.removeFromWishlist(product.id);
      return false;
    }
    await _localDataSource.saveToWishlist(product);
    return true;
  }
}
