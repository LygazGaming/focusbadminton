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
        stock: map['stock'] ?? 1,
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

    // Lấy thông tin sản phẩm mới nhất từ Firestore để đảm bảo có stock đúng
    final productDoc =
        await _firestore.collection('products').doc(product.id).get();
    int latestStock = 99; // Mặc định là 99 nếu không có thông tin

    if (productDoc.exists) {
      final productData = productDoc.data();
      if (productData != null && productData['stock'] != null) {
        latestStock = productData['stock'];
      }
    }

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
        'stock': latestStock, // Cập nhật stock mới nhất
      });
    } else {
      // Thêm sản phẩm mới vào giỏ hàng
      await _firestore.collection('users').doc(userId).collection('cart').add({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': quantity,
        'stock': latestStock, // Thêm thông tin về stock
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
      final data = existingDoc.data();
      final stock = data['stock'] ?? 99; // Lấy giá trị stock hiện tại

      if (quantity <= 0) {
        // Xóa sản phẩm nếu số lượng <= 0
        await existingDoc.reference.delete();
      } else {
        // Đảm bảo số lượng không vượt quá stock
        final updatedQuantity = quantity > stock ? stock : quantity;

        // Cập nhật số lượng, giữ nguyên stock
        await existingDoc.reference.update({
          'quantity': updatedQuantity,
          'stock': stock, // Giữ lại giá trị stock
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

  // Cập nhật thông tin stock cho sản phẩm trong giỏ hàng
  Future<void> updateProductStock(String productId, int stock) async {
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
      // Cập nhật stock cho sản phẩm trong giỏ hàng
      await existingDoc.reference.update({
        'stock': stock,
      });
    }
  }

  // Đồng bộ hóa thông tin stock từ sản phẩm gốc vào giỏ hàng
  Future<void> syncCartWithProductInfo() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      if (cartItems.docs.isEmpty) return;

      // Tạo batch để cập nhật nhiều tài liệu cùng lúc
      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (var doc in cartItems.docs) {
        final data = doc.data();
        final productId = data['productId'];

        if (productId == null) continue;

        // Lấy thông tin mới nhất từ collection products
        final productDoc =
            await _firestore.collection('products').doc(productId).get();

        if (productDoc.exists) {
          final productData = productDoc.data();
          if (productData != null) {
            // Mặc định stock là 99 nếu không có thông tin
            final latestStock = productData['stock'] ?? 99;

            // Nếu stock hiện tại khác với stock mới
            if (data['stock'] != latestStock) {
              batch.update(doc.reference, {'stock': latestStock});
              hasUpdates = true;
            }
          }
        }
      }

      // Thực hiện cập nhật batch nếu có thay đổi
      if (hasUpdates) {
        await batch.commit();
      }
    } catch (e) {
      print('Lỗi khi đồng bộ giỏ hàng: $e');
    }
  }
}
