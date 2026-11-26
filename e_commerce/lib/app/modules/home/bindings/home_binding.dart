import 'package:get/get.dart';

import 'package:e_commerce/app/core/network/dio_client.dart';
import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import 'package:e_commerce/app/data/local/product_local_datasource.dart';
import 'package:e_commerce/app/data/remote/product_remote_datasource.dart';
import 'package:e_commerce/app/data/repository/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core Network: DioClient terpusat
    Get.lazyPut<DioClient>(() => DioClient());

    // 2. Data Sources: Remote (REST API DummyJSON) & Local (Hive CE Box)
    Get.lazyPut<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(Get.find<DioClient>()));
    Get.lazyPut<ProductLocalDataSource>(() => ProductLocalDataSourceImpl());

    // 3. Repository: menerima Remote & Local DataSource
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(
        Get.find<ProductRemoteDataSource>(),
        Get.find<ProductLocalDataSource>(),
      ),
    );

    // 4. Controller Keranjang Global
    Get.lazyPut<CartLocalDataSource>(() => CartLocalDataSourceImpl(), fenix: true);
    Get.lazyPut<CartController>(
      () => CartController(localDataSource: Get.find<CartLocalDataSource>()),
      fenix: true,
    );

    // 5. HomeController menerima ProductRepository via constructor
    Get.lazyPut<HomeController>(() => HomeController(Get.find<ProductRepository>()));
  }
}
