import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

String formatRupiah(int amount) => _rupiah.format(amount);

class ProductModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final double rating;
  final String imageUrl;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.description = '',
  });

  String get formattedPrice => formatRupiah(price);

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        price: (map['price'] as num).toInt(),
        rating: (map['rating'] as num).toDouble(),
        imageUrl: map['imageUrl'] as String,
        description: map['description'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'rating': rating,
        'imageUrl': imageUrl,
        'description': description,
      };
}
