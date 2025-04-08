import 'package:flutter/material.dart';
import 'package:focusbadminton/models/product.dart';
import 'package:focusbadminton/screens/product_detail_screen.dart';
import 'package:focusbadminton/services/product_service.dart';
import 'package:focusbadminton/widgets/button.dart';
import 'package:focusbadminton/providers/home_screen_provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  final String? filter;

  const CategoryScreen({super.key, required this.category, this.filter});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ProductService _productService = ProductService();
  String _sortBy = 'newest'; // newest, price_asc, price_desc, rating
  late String _selectedCategory;

  final List<String> categories = [
    'Tất cả',
    'Vợt',
    'Giày',
    'Áo',
    'Quần',
    'Balo',
    'Ống cầu',
    'Phụ kiện',
  ];

  String? _filter;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu
    _selectedCategory = widget.category;
    _filter = widget.filter;
  }

  @override
  void didUpdateWidget(CategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật khi widget thay đổi
    if (oldWidget.category != widget.category ||
        oldWidget.filter != widget.filter) {
      setState(() {
        _selectedCategory = widget.category;
        _filter = widget.filter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tiêu đề và nút sắp xếp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'newest',
                    child: Text('Mới nhất'),
                  ),
                  const PopupMenuItem(
                    value: 'price_asc',
                    child: Text('Giá tăng dần'),
                  ),
                  const PopupMenuItem(
                    value: 'price_desc',
                    child: Text('Giá giảm dần'),
                  ),
                  const PopupMenuItem(
                    value: 'rating',
                    child: Text('Đánh giá cao nhất'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Danh mục sản phẩm bên trái
              SizedBox(
                width: 80,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                          // Xóa filter khi chọn danh mục mới
                          _filter = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue[900]
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Products grid bên phải
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: _getProductStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getEmptyStateIcon(),
                              size: 70,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getEmptyStateMessage(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              label: 'Quay lại trang chủ',
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                              ),
                              onPressed: () {
                                // Thay vì pop, chuyển về tab trang chủ an toàn hơn
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  // Nếu không thể pop, chuyển về tab trang chủ
                                  Provider.of<HomeScreenProvider>(context,
                                          listen: false)
                                      .setSelectedIndex(0);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    var products = snapshot.data!;

                    // Apply filter if specified
                    if (_filter != null) {
                      switch (_filter) {
                        case 'deal':
                          products = products.where((p) => p.isHot).toList();
                          break;
                        case 'flash_sale':
                          products = products.where((p) => p.isSale).toList();
                          break;
                        case 'seasonal':
                          // Lọc sản phẩm theo mùa
                          products =
                              products.where((p) => p.isSeasonal).toList();
                          break;
                        case 'combo':
                          // Lọc sản phẩm combo
                          products = products.where((p) => p.isCombo).toList();
                          break;
                        case 'brand_yonex':
                          products = products
                              .where((p) => p.brand == 'Yonex')
                              .toList();
                          break;
                        case 'brand_lining':
                          products = products
                              .where((p) => p.brand == 'Lining')
                              .toList();
                          break;
                        case 'brand_victor':
                          products = products
                              .where((p) => p.brand == 'Victor')
                              .toList();
                          break;
                        case 'brand_kawasaki':
                          products = products
                              .where((p) => p.brand == 'Kawasaki')
                              .toList();
                          break;
                      }
                    }

                    // Sort products based on selected option
                    switch (_sortBy) {
                      case 'price_asc':
                        products.sort((a, b) => a.price.compareTo(b.price));
                        break;
                      case 'price_desc':
                        products.sort((a, b) => b.price.compareTo(a.price));
                        break;
                      case 'rating':
                        products.sort((a, b) =>
                            (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
                        break;
                      default: // newest
                        products
                            .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(productId: product.id),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.grey.withAlpha(26), // 0.1 opacity
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product image
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: product.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Product info
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Product name
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // Brand
                                        Text(
                                          product.brand ??
                                              'Không có thương hiệu',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // Price
                                        Flexible(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  NumberFormat.currency(
                                                    locale: 'vi_VN',
                                                    symbol: '₫',
                                                    decimalDigits: 0,
                                                  ).format(product.price),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              if ((product.originalPrice ?? 0) >
                                                      product.price &&
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      400) ...[
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    NumberFormat.currency(
                                                      locale: 'vi_VN',
                                                      symbol: '₫',
                                                      decimalDigits: 0,
                                                    ).format(
                                                        product.originalPrice ??
                                                            product.price),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        // Rating
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.amber[700],
                                                size: 12),
                                            const SizedBox(width: 2),
                                            Text(
                                              (product.rating ?? 0.0)
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTitle() {
    if (_filter != null) {
      switch (_filter) {
        case 'deal':
          return 'Deal hấp dẫn';
        case 'flash_sale':
          return 'Flash Sale';
        case 'seasonal':
          return 'Sản phẩm theo mùa';
        case 'combo':
          return 'Combo tiết kiệm';
        case 'brand_yonex':
          return 'Thương hiệu: Yonex';
        case 'brand_lining':
          return 'Thương hiệu: Lining';
        case 'brand_victor':
          return 'Thương hiệu: Victor';
        case 'brand_kawasaki':
          return 'Thương hiệu: Kawasaki';
        default:
          return 'Danh mục: $_selectedCategory';
      }
    } else {
      return 'Danh mục: $_selectedCategory';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Vợt':
        return Icons.sports_tennis;
      case 'Giày':
        return Icons.directions_run;
      case 'Áo':
        return Icons.person;
      case 'Quần':
        return Icons.accessibility_new;
      case 'Balo':
        return Icons.backpack;
      case 'Ống cầu':
        return Icons.sports_cricket;
      case 'Phụ kiện':
        return Icons.settings;
      default:
        return Icons.category;
    }
  }

  // Phương thức để lấy stream sản phẩm phù hợp
  Stream<List<Product>> _getProductStream() {
    // Xử lý các trường hợp đặc biệt
    if (_selectedCategory == 'Mới') {
      return _productService.getNewProducts();
    } else if (_selectedCategory == 'Tất cả') {
      // Nếu có filter đặc biệt cho Tất cả
      if (_filter == 'seasonal') {
        return _productService.getSeasonalProducts();
      } else if (_filter == 'combo') {
        return _productService.getComboProducts();
      } else if (_filter == 'deal') {
        return _productService.getHotProducts();
      } else if (_filter == 'flash_sale') {
        return _productService.getSaleProducts();
      } else {
        return _productService.getAllProducts();
      }
    } else {
      return _productService.getProductsByCategory(_selectedCategory);
    }
  }

  // Lấy biểu tượng cho trạng thái trống
  IconData _getEmptyStateIcon() {
    if (_filter == 'combo') {
      return Icons.card_giftcard;
    } else if (_filter == 'seasonal') {
      return Icons.eco;
    } else if (_filter == 'deal') {
      return Icons.local_fire_department;
    } else if (_filter == 'flash_sale') {
      return Icons.bolt;
    } else if (_selectedCategory == 'Mới') {
      return Icons.new_releases;
    } else {
      return Icons.inventory_2;
    }
  }

  // Lấy thông báo cho trạng thái trống
  String _getEmptyStateMessage() {
    if (_filter == 'combo') {
      return 'Hiện tại chưa có sản phẩm combo nào\nVui lòng quay lại sau!';
    } else if (_filter == 'seasonal') {
      return 'Hiện tại chưa có sản phẩm theo mùa nào\nVui lòng quay lại sau!';
    } else if (_filter == 'deal') {
      return 'Hiện tại chưa có deal nào\nVui lòng quay lại sau!';
    } else if (_filter == 'flash_sale') {
      return 'Hiện tại chưa có flash sale nào\nVui lòng quay lại sau!';
    } else if (_selectedCategory == 'Mới') {
      return 'Hiện tại chưa có sản phẩm mới nào\nVui lòng quay lại sau!';
    } else {
      return 'Không tìm thấy sản phẩm nào\nVui lòng thử danh mục khác';
    }
  }
}
