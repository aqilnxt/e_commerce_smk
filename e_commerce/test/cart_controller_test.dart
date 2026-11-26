import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce/app/data/local/cart_local_datasource.dart';
import 'package:e_commerce/app/data/models/cart_item_model.dart';
import 'package:e_commerce/app/data/models/product_model.dart';
import 'package:e_commerce/app/modules/cart/controllers/cart_controller.dart';

const shoe = ProductModel(
  id: 'shoe-01',
  name: 'Sepatu',
  category: 'Casual',
  price: 1000000,
  rating: 4.5,
  imageUrl: '',
);

/// Penyimpanan palsu di memori untuk menggantikan box Hive
class MemoryCartDataSource implements CartLocalDataSource {
  final saved = <String, CartItemModel>{};

  @override
  List<CartItemModel> getCartItems() => saved.values.toList();

  @override
  Future<void> saveCartItem(CartItemModel item) async => saved[item.id] = item;

  @override
  Future<void> removeCartItem(String cartItemId) async => saved.remove(cartItemId);

  @override
  Future<void> clearCart() async => saved.clear();
}

void main() {
  test('ukuran sama digabung, ukuran beda jadi baris baru', () async {
    final cart = CartController();
    await cart.addItemAsync(shoe, quantity: 2, size: '42');
    await cart.addItemAsync(shoe, size: '42');
    await cart.addItemAsync(shoe, size: '43');
    expect(cart.items.length, 2);
    expect(cart.items.first.id, 'shoe-01_42');
    expect(cart.totalItemCount, 4);
  });

  test('PPN 11% dan ongkir gratis mulai Rp 2.000.000', () async {
    final cart = CartController();
    expect(cart.totalAmount, 0);

    await cart.addItemAsync(shoe);
    expect(cart.tax, 110000);
    expect(cart.shippingFee, CartController.flatShippingFee);
    expect(cart.totalAmount, 1135000);

    await cart.addItemAsync(shoe);
    expect(cart.shippingFee, 0);
    expect(cart.totalAmount, 2220000);
  });

  test('kuantitas nol menghapus item', () async {
    final cart = CartController();
    await cart.addItemAsync(shoe);
    final id = cart.items.first.id;
    await cart.increaseQuantity(id);
    expect(cart.totalItemCount, 2);
    await cart.decreaseQuantity(id);
    await cart.decreaseQuantity(id);
    expect(cart.items, isEmpty);
  });

  test('isi keranjang tersimpan dan dimuat ulang dari penyimpanan', () async {
    final storage = MemoryCartDataSource();
    final cart = CartController(localDataSource: storage);
    await cart.addItemAsync(shoe, quantity: 2, size: '41');
    await cart.increaseQuantity('shoe-01_41');
    expect(storage.saved['shoe-01_41']!.quantity, 3);

    final reopened = CartController(localDataSource: storage)..onInit();
    expect(reopened.totalItemCount, 3);

    await reopened.clearCartAsync();
    expect(storage.saved, isEmpty);
  });

  test('model bolak-balik lewat map', () {
    final restored = ProductModel.fromMap(shoe.toMap());
    expect(restored.price, shoe.price);
    expect(restored.formattedPrice, 'Rp 1.000.000');
  });
}
