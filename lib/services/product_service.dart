import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'dart:developer' as developer;

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả sản phẩm
  Stream<List<Product>> getAllProducts() {
    developer.log('Bắt đầu lấy tất cả sản phẩm');
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('Số lượng sản phẩm từ Firestore: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        developer.log('Đang xử lý sản phẩm: ${doc.id}');
        return Product.fromFirestore(doc);
      }).toList();
    });
  }

  // Lấy sản phẩm theo category
  Stream<List<Product>> getProductsByCategory(String category) {
    developer.log('Bắt đầu lấy sản phẩm theo category: $category');
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log(
          'Số lượng sản phẩm theo category $category: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Lấy sản phẩm theo ID
  Future<Product?> getProductById(String id) async {
    developer.log('Bắt đầu lấy sản phẩm theo ID: $id');
    final doc = await _firestore.collection('products').doc(id).get();
    if (!doc.exists) {
      developer.log('Không tìm thấy sản phẩm với ID: $id');
      return null;
    }
    developer.log('Đã tìm thấy sản phẩm: ${doc.id}');
    return Product.fromFirestore(doc);
  }

  // Lấy sản phẩm đang giảm giá
  Stream<List<Product>> getSaleProducts() {
    developer.log('Bắt đầu lấy sản phẩm đang giảm giá');
    return _firestore
        .collection('products')
        .where('isSale', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('Số lượng sản phẩm đang giảm giá: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Lấy sản phẩm mới
  Stream<List<Product>> getNewProducts() {
    developer.log('Bắt đầu lấy sản phẩm mới');
    return _firestore
        .collection('products')
        .where('isNew', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('Số lượng sản phẩm mới: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Lấy sản phẩm hot
  Stream<List<Product>> getHotProducts() {
    developer.log('Bắt đầu lấy sản phẩm hot');
    return _firestore
        .collection('products')
        .where('isHot', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('Số lượng sản phẩm hot: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Lấy sản phẩm combo
  Stream<List<Product>> getComboProducts() {
    developer.log('Bắt đầu lấy sản phẩm combo');
    return _firestore
        .collection('products')
        .where('isCombo', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('Số lượng sản phẩm combo: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Lấy sản phẩm theo mùa
  Stream<List<Product>> getSeasonalProducts() {
    developer.log('Bắt đầu lấy sản phẩm theo mùa');
    return _firestore
        .collection('products')
        .where('isSeasonal', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('Số lượng sản phẩm theo mùa: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Tìm kiếm sản phẩm
  Stream<List<Product>> searchProducts(String query) {
    developer.log('Bắt đầu tìm kiếm sản phẩm với từ khóa: $query');
    return _firestore
        .collection('products')
        .orderBy('name')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
          developer.log('Số lượng sản phẩm tìm thấy: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();
        });
  }

  // Lấy sản phẩm theo danh mục và tìm kiếm
  Stream<List<Product>> getProductsByCategoryAndSearch(
      String category, String query) {
    developer.log(
        'Bắt đầu tìm kiếm sản phẩm theo category: $category và từ khóa: $query');
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .orderBy('name')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
          developer.log('Số lượng sản phẩm tìm thấy: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();
        });
  }

  // Lấy sản phẩm theo thương hiệu
  Stream<List<Product>> getProductsByBrand(String brand) {
    developer.log('Bắt đầu lấy sản phẩm theo thương hiệu: $brand');
    return _firestore
        .collection('products')
        .where('brand', isEqualTo: brand)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log(
          'Số lượng sản phẩm theo thương hiệu $brand: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }
}
