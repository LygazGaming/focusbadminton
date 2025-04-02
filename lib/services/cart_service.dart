import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      product: Product(
        id: map['productId'] ?? id,
        name: map['name'] ?? '',
        price: map['price'] ?? 0.0,
        description: map['description'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        category: map['category'] ?? '',
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      ),
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy giỏ hàng của người dùng hiện tại
  Stream<List<CartItem>> getCartItems() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(Product product, [int quantity = 1]) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Kiểm tra sản phẩm đã có trong giỏ hàng chưa
    final cartItemRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .where('productId', isEqualTo: product.id);

    final cartItemDocs = await cartItemRef.get();

    if (cartItemDocs.docs.isNotEmpty) {
      // Sản phẩm đã có trong giỏ hàng, cập nhật số lượng
      final existingDoc = cartItemDocs.docs.first;
      final existingQuantity = existingDoc.data()['quantity'] ?? 0;
      await existingDoc.reference.update({
        'quantity': existingQuantity + quantity,
      });
    } else {
      // Thêm sản phẩm mới vào giỏ hàng
      await _firestore.collection('users').doc(userId).collection('cart').add({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  Future<void> updateQuantity(String productId, int quantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartItemRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .where('productId', isEqualTo: productId);

    final cartItemDocs = await cartItemRef.get();

    if (cartItemDocs.docs.isNotEmpty) {
      final existingDoc = cartItemDocs.docs.first;
      if (quantity <= 0) {
        // Xóa sản phẩm nếu số lượng <= 0
        await existingDoc.reference.delete();
      } else {
        // Cập nhật số lượng
        await existingDoc.reference.update({
          'quantity': quantity,
        });
      }
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartItemRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .where('productId', isEqualTo: productId);

    final cartItemDocs = await cartItemRef.get();

    if (cartItemDocs.docs.isNotEmpty) {
      final existingDoc = cartItemDocs.docs.first;
      await existingDoc.reference.delete();
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartItems = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    final batch = _firestore.batch();
    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Lấy tổng giá trị giỏ hàng
  Future<double> getCartTotal() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    final cartItems = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    double total = 0;
    for (var doc in cartItems.docs) {
      final data = doc.data();
      final price = data['price'] ?? 0.0;
      final quantity = data['quantity'] ?? 1;
      total += (price * quantity);
    }

    return total;
  }

  // Trả về số lượng sản phẩm trong giỏ hàng
  Stream<int> getCartItemCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
