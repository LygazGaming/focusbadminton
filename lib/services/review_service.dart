import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusbadminton/models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách đánh giá của sản phẩm
  Future<List<Review>> getReviewsByProductId(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  // Thêm đánh giá mới
  Future<Review?> addReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Bạn cần đăng nhập để đánh giá sản phẩm');
      }

      // Kiểm tra xem người dùng đã đánh giá sản phẩm này chưa
      final existingReview = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingReview.docs.isNotEmpty) {
        // Cập nhật đánh giá hiện có
        final reviewId = existingReview.docs.first.id;
        await _firestore.collection('reviews').doc(reviewId).update({
          'rating': rating,
          'comment': comment,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Lấy đánh giá đã cập nhật
        final updatedReview =
            await _firestore.collection('reviews').doc(reviewId).get();
        return Review.fromMap(updatedReview.data()!, reviewId);
      } else {
        // Tạo đánh giá mới
        final reviewData = {
          'productId': productId,
          'userId': user.uid,
          'userName': user.displayName ?? 'Người dùng ẩn danh',
          'userPhotoUrl': user.photoURL,
          'rating': rating,
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(),
        };

        final docRef = await _firestore.collection('reviews').add(reviewData);

        // Lấy đánh giá đã tạo
        final newReview = await docRef.get();

        // Cập nhật thông tin đánh giá trong sản phẩm
        await _updateProductRating(productId);

        return Review.fromMap(newReview.data()!, docRef.id);
      }
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  // Xóa đánh giá
  Future<void> deleteReview(String reviewId, String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Bạn cần đăng nhập để xóa đánh giá');
      }

      // Kiểm tra xem đánh giá có thuộc về người dùng hiện tại không
      final review = await _firestore.collection('reviews').doc(reviewId).get();
      if (review.exists && review.data()?['userId'] == user.uid) {
        await _firestore.collection('reviews').doc(reviewId).delete();

        // Cập nhật thông tin đánh giá trong sản phẩm
        await _updateProductRating(productId);
      } else {
        throw Exception('Bạn không có quyền xóa đánh giá này');
      }
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }

  // Kiểm tra xem người dùng đã đánh giá sản phẩm chưa
  Future<Review?> getUserReview(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return Review.fromMap(doc.data(), doc.id);
    } catch (e) {
      print('Error getting user review: $e');
      return null;
    }
  }

  // Cập nhật thông tin đánh giá trong sản phẩm
  Future<void> _updateProductRating(String productId) async {
    try {
      // Lấy tất cả đánh giá của sản phẩm
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      final reviews = querySnapshot.docs;

      if (reviews.isEmpty) {
        // Nếu không có đánh giá nào, đặt rating = 0 và reviewCount = 0
        await _firestore.collection('products').doc(productId).update({
          'rating': 0.0,
          'reviewCount': 0,
        });
        return;
      }

      // Tính toán rating trung bình
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += (review.data()['rating'] as num).toDouble();
      }

      final averageRating = totalRating / reviews.length;

      // Cập nhật thông tin đánh giá trong sản phẩm
      await _firestore.collection('products').doc(productId).update({
        'rating': averageRating,
        'reviewCount': reviews.length,
      });
    } catch (e) {
      print('Error updating product rating: $e');
    }
  }
}
