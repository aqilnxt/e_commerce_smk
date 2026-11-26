import 'package:get/get.dart';

import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartLocalDataSource>(() => CartLocalDataSourceImpl(), fenix: true);
    Get.lazyPut<CartController>(
      () => CartController(localDataSource: Get.find<CartLocalDataSource>()),
      fenix: true,
    );
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
