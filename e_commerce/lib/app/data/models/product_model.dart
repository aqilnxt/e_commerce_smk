import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

String formatRupiah(int amount) => _rupiah.format(amount);

class ProductModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String description;
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    this.reviewCount = 120,
    required this.imageUrl,
    this.description = '',
    this.isFavorite = false,
  });

  String get formattedPrice => formatRupiah(price);

  // Deserialisasi defensif dari JSON DummyJSON: field kosong, null, atau tipe berbeda tetap aman.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId != null ? rawId.toString() : 'prod-${DateTime.now().millisecondsSinceEpoch}';

    final name = (json['title'] ?? json['name'] ?? 'Sepatu Sneakers').toString();
    final rawCategory = (json['category'] ?? 'Lifestyle').toString();
    final category = rawCategory.isNotEmpty
        ? '${rawCategory[0].toUpperCase()}${rawCategory.substring(1)}'
        : 'General';

    // Konversi harga: jika nilai < 1000 (USD DummyJSON), kalikan kurs Rupiah 15.000
    final rawPrice = (json['price'] as num?)?.toInt() ?? 150000;
    final price = rawPrice < 1000 ? rawPrice * 15000 : rawPrice;

    final rating = (json['rating'] as num?)?.toDouble() ?? 4.8;
    final imageUrl =
        (json['thumbnail'] ??
                json['imageUrl'] ??
                'https://images.unsplash.com/photo-1542291026-7eec264c27ff')
            .toString();
    final description = (json['description'] ?? 'Sepatu sneakers berkualitas tinggi.').toString();

    return ProductModel(
      id: id,
      name: name,
      category: category,
      price: price,
      rating: rating,
      reviewCount: 50 + (price % 150),
      imageUrl: imageUrl,
      description: description,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
    id: map['id'] as String,
    name: map['name'] as String,
    category: map['category'] as String,
    price: (map['price'] as num).toInt(),
    rating: (map['rating'] as num).toDouble(),
    reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 120,
    imageUrl: map['imageUrl'] as String,
    description: map['description'] as String? ?? '',
    isFavorite: map['isFavorite'] as bool? ?? false,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'rating': rating,
    'reviewCount': reviewCount,
    'imageUrl': imageUrl,
    'description': description,
    'isFavorite': isFavorite,
  };
}
