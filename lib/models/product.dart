import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  final String? brand;
  final int? stock;
  final double? rating;
  final int? reviewCount;
  final double? originalPrice;
  final List<String>? specifications;
  final Map<String, dynamic>? details;
  final bool isAvailable;
  final DateTime createdAt;
  final bool isHot;
  final bool isNew;
  final bool isSale;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.brand,
    this.stock,
    this.rating,
    this.reviewCount,
    this.originalPrice,
    this.specifications,
    this.details,
    this.isAvailable = true,
    required this.createdAt,
    this.isHot = false,
    this.isNew = false,
    this.isSale = false,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'],
      stock: map['stock'],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      reviewCount: map['reviewCount'],
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : null,
      specifications: map['specifications'] != null
          ? List<String>.from(map['specifications'])
          : null,
      details: map['details'],
      isAvailable: map['isAvailable'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isHot: map['isHot'] ?? false,
      isNew: map['isNew'] ?? false,
      isSale: map['isSale'] ?? false,
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] ?? 0.0),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'],
      stock: data['stock'],
      rating:
          data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      reviewCount: data['reviewCount'],
      originalPrice: data['originalPrice'] != null
          ? (data['originalPrice'] as num).toDouble()
          : null,
      specifications: data['specifications'] != null
          ? List<String>.from(data['specifications'])
          : null,
      details: data['details'],
      isAvailable: data['isAvailable'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isHot: data['isHot'] ?? false,
      isNew: data['isNew'] ?? false,
      isSale: data['isSale'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'originalPrice': originalPrice,
      'specifications': specifications,
      'details': details,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'isHot': isHot,
      'isNew': isNew,
      'isSale': isSale,
    };
  }

  Product copyWith({
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? category,
    String? brand,
    int? stock,
    double? rating,
    int? reviewCount,
    double? originalPrice,
    List<String>? specifications,
    Map<String, dynamic>? details,
    bool? isAvailable,
    DateTime? createdAt,
    bool? isHot,
    bool? isNew,
    bool? isSale,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      originalPrice: originalPrice ?? this.originalPrice,
      specifications: specifications ?? this.specifications,
      details: details ?? this.details,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      isHot: isHot ?? this.isHot,
      isNew: isNew ?? this.isNew,
      isSale: isSale ?? this.isSale,
    );
  }
}
