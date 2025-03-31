import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final String brand;
  final String category;
  final List<String> specifications;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isHot;
  final bool isSale;
  final double discountPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.brand,
    required this.category,
    required this.specifications,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    required this.isNew,
    required this.isHot,
    required this.isSale,
    required this.discountPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      specifications: List<String>.from(data['specifications'] ?? []),
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isNew: data['isNew'] ?? false,
      isHot: data['isHot'] ?? false,
      isSale: data['isSale'] ?? false,
      discountPercentage: (data['discountPercentage'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'brand': brand,
      'category': category,
      'specifications': specifications,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isNew': isNew,
      'isHot': isHot,
      'isSale': isSale,
      'discountPercentage': discountPercentage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
