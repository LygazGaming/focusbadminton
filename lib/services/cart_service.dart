import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusbadminton/models/product.dart';

class CartItem {
  final String productId;
  final int quantity;
  Product? product;

  CartItem({
    required this.productId,
    required this.quantity,
    this.product,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      quantity: map['quantity'],
    );
  }
}

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy giỏ hàng của người dùng
  Stream<List<CartItem>> getCartItems() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList());
  }

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(String productId, int quantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    final doc = await cartRef.get();
    if (doc.exists) {
      // Cập nhật số lượng nếu sản phẩm đã tồn tại
      await cartRef.update({
        'quantity': FieldValue.increment(quantity),
      });
    } else {
      // Thêm mới nếu sản phẩm chưa tồn tại
      await cartRef.set({
        'productId': productId,
        'quantity': quantity,
      });
    }
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  Future<void> updateQuantity(String productId, int quantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    if (quantity <= 0) {
      // Xóa sản phẩm nếu số lượng <= 0
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } else {
      // Cập nhật số lượng
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .update({
        'quantity': quantity,
      });
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();
    final cartItems = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
