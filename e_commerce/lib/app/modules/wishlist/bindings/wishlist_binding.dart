import 'package:get/get.dart';

import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/remote/product_remote_datasource.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';
import '../controllers/wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductLocalDataSource>()) {
      Get.lazyPut<ProductLocalDataSource>(() => ProductLocalDataSourceImpl());
    }
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepositoryImpl(
          Get.find<ProductRemoteDataSource>(),
          Get.find<ProductLocalDataSource>(),
        ),
      );
    }

    Get.lazyPut<WishlistController>(() => WishlistController(Get.find<ProductRepository>()));
  }
}
