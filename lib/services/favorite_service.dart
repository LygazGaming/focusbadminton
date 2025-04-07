import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusbadminton/models/product.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy ID của người dùng hiện tại
  String? get _userId => _auth.currentUser?.uid;

  // Kiểm tra xem người dùng đã đăng nhập chưa
  bool get isLoggedIn => _userId != null;

  // Lấy reference đến collection favorites của người dùng
  CollectionReference get _favoritesRef =>
      _firestore.collection('users').doc(_userId).collection('favorites');

  // Thêm sản phẩm vào danh sách yêu thích
  Future<void> addToFavorites(Product product) async {
    if (!isLoggedIn) {
      throw Exception(
          'Bạn cần đăng nhập để thêm sản phẩm vào danh sách yêu thích');
    }

    await _favoritesRef.doc(product.id).set({
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'imageUrl': product.imageUrl,
      'brand': product.brand,
      'isNew': product.isNew,
      'isHot': product.isHot,
      'isSale': product.isSale,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Xóa sản phẩm khỏi danh sách yêu thích
  Future<void> removeFromFavorites(String productId) async {
    if (!isLoggedIn) {
      throw Exception(
          'Bạn cần đăng nhập để xóa sản phẩm khỏi danh sách yêu thích');
    }

    await _favoritesRef.doc(productId).delete();
  }

  // Kiểm tra xem sản phẩm có trong danh sách yêu thích không
  Future<bool> isFavorite(String productId) async {
    if (!isLoggedIn) return false;

    final doc = await _favoritesRef.doc(productId).get();
    return doc.exists;
  }

  // Lấy danh sách sản phẩm yêu thích
  Stream<List<Product>> getFavorites() {
    if (!isLoggedIn) {
      return Stream.value([]);
    }

    return _favoritesRef
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: data['productId'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          originalPrice: data['originalPrice'] != null
              ? (data['originalPrice'] as num).toDouble()
              : null,
          imageUrl: data['imageUrl'] ?? '',
          description: '',
          brand: data['brand'],
          category: '',
          isNew: data['isNew'] ?? false,
          isHot: data['isHot'] ?? false,
          isSale: data['isSale'] ?? false,
          createdAt: DateTime.now(),
        );
      }).toList();
    });
  }

  // Toggle trạng thái yêu thích của sản phẩm
  Future<bool> toggleFavorite(Product product) async {
    if (!isLoggedIn) {
      throw Exception(
          'Bạn cần đăng nhập để thêm/xóa sản phẩm khỏi danh sách yêu thích');
    }

    final isFav = await isFavorite(product.id);
    if (isFav) {
      await removeFromFavorites(product.id);
      return false;
    } else {
      await addToFavorites(product);
      return true;
    }
  }
}
