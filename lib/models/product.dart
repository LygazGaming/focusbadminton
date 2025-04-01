import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String? brand;
  final String category;
  final List<String>? specifications;
  final int? stock;
  final double? rating;
  final int? reviewCount;
  final bool? isNew;
  final bool? isHot;
  final bool? isSale;
  final double? discountPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.brand,
    required this.category,
    this.specifications,
    this.stock,
    this.rating,
    this.reviewCount,
    this.isNew,
    this.isHot,
    this.isSale,
    this.discountPercentage,
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
      originalPrice: data['originalPrice'] != null
          ? (data['originalPrice'] as num).toDouble()
          : null,
      imageUrl: data['imageUrl'] ?? '',
      brand: data['brand'],
      category: data['category'] ?? '',
      specifications: data['specifications'] != null
          ? List<String>.from(data['specifications'])
          : null,
      stock: data['stock'],
      rating:
          data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      reviewCount: data['reviewCount'],
      isNew: data['isNew'],
      isHot: data['isHot'],
      isSale: data['isSale'],
      discountPercentage: data['discountPercentage'] != null
          ? (data['discountPercentage'] as num).toDouble()
          : null,
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
