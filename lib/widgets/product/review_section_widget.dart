import 'package:flutter/material.dart';
import 'package:focusbadminton/models/review.dart';
import 'package:focusbadminton/services/review_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReviewSectionWidget extends StatefulWidget {
  final String productId;

  const ReviewSectionWidget({
    super.key,
    required this.productId,
  });

  @override
  State<ReviewSectionWidget> createState() => _ReviewSectionWidgetState();
}

class _ReviewSectionWidgetState extends State<ReviewSectionWidget> {
  final ReviewService _reviewService = ReviewService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  Review? _userReview;

  // Controller cho form đánh giá
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 5.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Tải danh sách đánh giá
  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reviews =
          await _reviewService.getReviewsByProductId(widget.productId);
      final userReview = await _reviewService.getUserReview(widget.productId);

      setState(() {
        _reviews = reviews;
        _userReview = userReview;

        if (userReview != null) {
          _commentController.text = userReview.comment;
          _userRating = userReview.rating;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải đánh giá: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Gửi đánh giá mới
  Future<void> _submitReview() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để đánh giá sản phẩm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reviewService.addReview(
        productId: widget.productId,
        rating: _userRating,
        comment: _commentController.text.trim(),
      );

      // Tải lại danh sách đánh giá
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá của bạn đã được gửi thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi đánh giá: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Xóa đánh giá
  Future<void> _deleteReview() async {
    if (_userReview == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reviewService.deleteReview(_userReview!.id, widget.productId);

      // Tải lại danh sách đánh giá
      await _loadReviews();

      // Reset form
      setState(() {
        _commentController.text = '';
        _userRating = 5.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá của bạn đã được xóa'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa đánh giá: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Danh sách đánh giá
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reviews.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Chưa có đánh giá nào cho sản phẩm này',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reviews.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return _buildReviewItem(review);
                    },
                  ),

        const SizedBox(height: 16),

        // Form đánh giá
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Viết đánh giá của bạn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildReviewForm(),
      ],
    );
  }

  // Widget hiển thị form đánh giá
  Widget _buildReviewForm() {
    final user = _auth.currentUser;

    if (user == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Text(
                'Bạn cần đăng nhập để đánh giá sản phẩm',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị tên người dùng
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? Icon(
                        Icons.person,
                        color: Colors.grey[400],
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.displayName ?? 'Người dùng ẩn danh',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Hiển thị rating
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Text('Đánh giá của bạn: '),
              _buildRatingBar(),
            ],
          ),

          const SizedBox(height: 16),

          // Hiển thị text field để nhập đánh giá
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập đánh giá của bạn về sản phẩm này...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),

          const SizedBox(height: 16),

          // Nút gửi đánh giá
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_userReview != null)
                TextButton(
                  onPressed: _isSubmitting ? null : _deleteReview,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Xóa đánh giá'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_userReview == null
                        ? 'Gửi đánh giá'
                        : 'Cập nhật đánh giá'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget hiển thị rating bar
  Widget _buildRatingBar() {
    return Wrap(
      spacing: 0,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _userRating.floor()
                ? Icons.star
                : (index < _userRating ? Icons.star_half : Icons.star_border),
            color: Colors.amber,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(maxWidth: 30),
          onPressed: () {
            setState(() {
              if (index == 0 && _userRating == 1) {
                // Nếu nhấn vào sao đầu tiên và rating hiện tại là 1, đặt rating = 0
                _userRating = 0;
              } else {
                // Ngược lại, đặt rating = index + 1
                _userRating = index + 1.0;
              }
            });
          },
        );
      }),
    );
  }

  // Widget hiển thị một đánh giá
  Widget _buildReviewItem(Review review) {
    final isUserReview = _auth.currentUser?.uid == review.userId;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar người dùng
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: review.userPhotoUrl != null
                    ? NetworkImage(review.userPhotoUrl!)
                    : null,
                child: review.userPhotoUrl == null
                    ? Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey[400],
                      )
                    : null,
              ),

              const SizedBox(width: 8),

              // Tên người dùng
              Expanded(
                child: Text(
                  review.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (isUserReview)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Của bạn',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),

              const Spacer(),

              // Ngày đánh giá
              Text(
                DateFormat('dd/MM/yyyy').format(review.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Rating
          Wrap(
            spacing: 0,
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating.floor()
                    ? Icons.star
                    : (index < review.rating
                        ? Icons.star_half
                        : Icons.star_border),
                color: Colors.amber,
                size: 16,
              );
            }),
          ),

          const SizedBox(height: 8),

          // Nội dung đánh giá
          Text(
            review.comment,
            style: const TextStyle(height: 1.5),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
