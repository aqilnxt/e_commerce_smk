import 'package:get/get.dart';

import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import '../controllers/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartLocalDataSource>(() => CartLocalDataSourceImpl(), fenix: true);
    Get.lazyPut<CartController>(
      () => CartController(localDataSource: Get.find<CartLocalDataSource>()),
      fenix: true,
    );
  }
}
