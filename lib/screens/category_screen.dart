import 'package:flutter/material.dart';
import 'package:focusbadminton/models/product.dart';
import 'package:focusbadminton/screens/product_detail_screen.dart';
import 'package:focusbadminton/services/product_service.dart';
import 'package:focusbadminton/widgets/button.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
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
      body: Row(
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[900] : Colors.transparent,
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
                            color: isSelected ? Colors.white : Colors.grey[700],
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
                              color:
                                  isSelected ? Colors.white : Colors.grey[800],
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
              stream: _selectedCategory == 'Tất cả'
                  ? _productService.getAllProducts()
                  : _productService.getProductsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Không có sản phẩm nào',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Quay lại',
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                          ),
                          onPressed: () => Navigator.pop(context),
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
                      // Giả sử rằng sản phẩm theo mùa có tag isNew
                      products = products.where((p) => p.isNew).toList();
                      break;
                    case 'combo':
                      // Giả sử rằng combo có originalPrice
                      products = products
                          .where((p) => p.originalPrice != null)
                          .toList();
                      break;
                    case 'brand_yonex':
                      products =
                          products.where((p) => p.brand == 'Yonex').toList();
                      break;
                    case 'brand_lining':
                      products =
                          products.where((p) => p.brand == 'Lining').toList();
                      break;
                    case 'brand_victor':
                      products =
                          products.where((p) => p.brand == 'Victor').toList();
                      break;
                    case 'brand_kawasaki':
                      products =
                          products.where((p) => p.brand == 'Kawasaki').toList();
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
                    products.sort(
                        (a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
                    break;
                  default: // newest
                    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              color: Colors.grey.withOpacity(0.1),
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
                                    placeholder: (context, url) => Container(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      product.brand ?? 'Không có thương hiệu',
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
                                              overflow: TextOverflow.ellipsis,
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
                                                overflow: TextOverflow.ellipsis,
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
                                            color: Colors.amber[700], size: 12),
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
}
