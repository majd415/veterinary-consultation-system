import 'package:get/get.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final String image;
  final int categoryId;
  final String categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.image,
    required this.categoryId,
    this.categoryName = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper to get localized string
    String getLocalized(dynamic val) {
      if (val is Map) {
        final locale = Get.locale?.languageCode ?? 'en';
        return val[locale] ?? val['en'] ?? val.values.first ?? '';
      }
      return val.toString();
    }

    String catName = '';
    if (json['category'] != null) {
      catName = getLocalized(json['category']['name']);
    }

    return Product(
      id: json['id'],
      name: getLocalized(json['name']),
      description: getLocalized(json['description']),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      rating: double.tryParse(json['rate'].toString()) ?? 0.0,
      image: json['image'] ?? 'assets/images/food.png',
      categoryId: json['category_id'] ?? 0,
      categoryName: catName,
    );
  }
}
