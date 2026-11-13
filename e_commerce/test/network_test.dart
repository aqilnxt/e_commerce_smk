import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce/app/core/network/dio_exception.dart';
import 'package:e_commerce/app/data/models/product_model.dart';

void main() {
  test('fromJson tahan data kosong dan mengonversi USD ke Rupiah', () {
    final product = ProductModel.fromJson({
      'id': 7,
      'title': 'Nike Air',
      'category': 'mens-shoes',
      'price': 89.99,
      'rating': 5,
    });
    expect(product.id, '7');
    expect(product.category, 'Mens-shoes');
    expect(product.price, 89 * 15000);
    expect(product.rating, 5.0);

    final empty = ProductModel.fromJson({});
    expect(empty.name, 'Sepatu Sneakers');
    expect(empty.price, 150000);
    expect(empty.imageUrl, isNotEmpty);
  });

  test('ErrorHandler menerjemahkan error Dio ke pesan Indonesia', () {
    final options = RequestOptions(path: '/products');
    expect(
      ErrorHandler.handle(
        DioException(requestOptions: options, type: DioExceptionType.connectionTimeout),
      ).failure.code,
      -1,
    );
    final notFound = ErrorHandler.handle(
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 404),
      ),
    ).failure;
    expect(notFound.code, 404);
    expect(notFound.message, contains('404'));
  });
}
