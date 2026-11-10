import 'package:get/get.dart';

import '../../cart/controllers/cart_controller.dart';
import '../controllers/detail_controller.dart';

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailController>(
      () => DetailController(),
    );
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}
