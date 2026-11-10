import 'package:flutter_test/flutter_test.dart';

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

void main() {
  test('ukuran sama digabung, ukuran beda jadi baris baru', () {
    final cart = CartController()
      ..addItem(shoe, quantity: 2, size: '42')
      ..addItem(shoe, size: '42')
      ..addItem(shoe, size: '43');
    expect(cart.items.length, 2);
    expect(cart.items.first.id, 'shoe-01_42');
    expect(cart.totalItemCount, 4);
  });

  test('PPN 11% dan ongkir gratis mulai Rp 2.000.000', () {
    final cart = CartController();
    expect(cart.totalAmount, 0);

    cart.addItem(shoe);
    expect(cart.tax, 110000);
    expect(cart.shippingFee, CartController.flatShippingFee);
    expect(cart.totalAmount, 1135000);

    cart.addItem(shoe);
    expect(cart.shippingFee, 0);
    expect(cart.totalAmount, 2220000);
  });

  test('kuantitas nol menghapus item', () {
    final cart = CartController()..addItem(shoe);
    final id = cart.items.first.id;
    cart.increaseQuantity(id);
    expect(cart.totalItemCount, 2);
    cart.decreaseQuantity(id);
    cart.decreaseQuantity(id);
    expect(cart.items, isEmpty);
  });

  test('model bolak-balik lewat map', () {
    final restored = ProductModel.fromMap(shoe.toMap());
    expect(restored.id, shoe.id);
    expect(restored.price, shoe.price);
    expect(restored.formattedPrice, 'Rp 1.000.000');
  });
}
