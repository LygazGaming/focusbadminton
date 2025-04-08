import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focusbadminton/models/product.dart';
import 'package:focusbadminton/services/product_service.dart';
import 'package:focusbadminton/services/cart_service.dart';
import 'package:focusbadminton/services/favorite_service.dart';
import 'package:focusbadminton/widgets/product/review_section_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _productService = ProductService();
  final _cartService = CartService();
  final _favoriteService = FavoriteService();
  Product? _product;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _checkingFavorite = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await _productService.getProductById(widget.productId);
      bool isFav = false;

      // Kiểm tra xem sản phẩm có trong danh sách yêu thích không
      try {
        isFav = await _favoriteService.isFavorite(widget.productId);
      } catch (e) {
        // Không làm gì nếu có lỗi khi kiểm tra yêu thích
      }

      if (mounted) {
        setState(() {
          _product = product;
          _isFavorite = isFav;
          _isLoading = false;
          _checkingFavorite = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _checkingFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải thông tin sản phẩm'),
          ),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    try {
      await _cartService.addToCart(_product!, _quantity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm sản phẩm vào giỏ hàng'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể thêm sản phẩm vào giỏ hàng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_product == null) return;

    try {
      final isNowFavorite = await _favoriteService.toggleFavorite(_product!);
      if (mounted) {
        setState(() {
          _isFavorite = isNowFavorite;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowFavorite
                  ? 'Đã thêm vào danh sách yêu thích'
                  : 'Đã xóa khỏi danh sách yêu thích',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Phương thức để chia sẻ thông tin sản phẩm
  void _shareProduct() {
    if (_product == null) return;

    try {
      // Tạo nội dung chia sẻ
      final String productName = _product!.name;
      final String productPrice = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: '₫',
        decimalDigits: 0,
      ).format(_product!.price);

      final String shareText =
          'Đã tìm thấy sản phẩm tuyệt vời trên ứng dụng Focus Badminton!\n\n'
          '$productName\n'
          'Giá: $productPrice\n\n'
          'Mã sản phẩm: ${_product!.id}\n'
          'Bạn có thể tìm sản phẩm này trong ứng dụng Focus Badminton.';

      // Sao chép vào clipboard
      Clipboard.setData(ClipboardData(text: shareText));

      // Hiển thị menu tùy chọn
      _showShareOptions(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chia sẻ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Hiển thị menu tùy chọn chia sẻ
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chia sẻ sản phẩm',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Đã sao chép thông tin sản phẩm vào clipboard',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: 'Tin nhắn',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Đã sao chép thông tin sản phẩm. Bạn có thể dán vào tin nhắn'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.chat_bubble,
                  label: 'Zalo',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Đã sao chép thông tin sản phẩm. Bạn có thể dán vào Zalo'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Đã sao chép thông tin sản phẩm. Bạn có thể dán vào Facebook'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Đã sao chép thông tin sản phẩm. Bạn có thể dán vào email'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị tùy chọn chia sẻ
  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue[900], size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết sản phẩm'),
        ),
        body: const Center(
          child: Text('Không tìm thấy sản phẩm'),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ),
            actions: [
              // Nút yêu thích
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
                onPressed: _checkingFavorite ? null : _toggleFavorite,
              ),
              // Nút chia sẻ
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareProduct,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Brand
                  Text(
                    product.brand ?? 'Không có thương hiệu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Price
                  Row(
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: '₫',
                          decimalDigits: 0,
                        ).format(product.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      if ((product.originalPrice ?? 0) > product.price) ...[
                        const SizedBox(width: 8),
                        Text(
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: '₫',
                            decimalDigits: 0,
                          ).format(product.originalPrice ?? product.price),
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        (product.rating ?? 0.0).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${product.reviewCount ?? 0} đánh giá)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specifications
                  const Text(
                    'Thông số kỹ thuật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(product.specifications ?? []).map((spec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                spec,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 24),

                  // Đánh giá sản phẩm
                  const Divider(),
                  const Text(
                    'Đánh giá từ khách hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ReviewSectionWidget(productId: product.id),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1
                        ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _quantity < (product.stock ?? 99)
                        ? () {
                            setState(() {
                              _quantity++;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to cart button
            Expanded(
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
