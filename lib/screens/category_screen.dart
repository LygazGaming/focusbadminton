import 'package:flutter/material.dart';
import 'package:focusbadminton/models/product.dart';
import 'package:focusbadminton/screens/product_detail_screen.dart';
import 'package:focusbadminton/services/product_service.dart';
import 'package:focusbadminton/widgets/button.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ProductService _productService = ProductService();
  String _sortBy = 'newest'; // newest, price_asc, price_desc, rating

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
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
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProductsByCategory(widget.category),
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
          // Sort products based on selected option
          switch (_sortBy) {
            case 'price_asc':
              products.sort((a, b) => a.price.compareTo(b.price));
              break;
            case 'price_desc':
              products.sort((a, b) => b.price.compareTo(a.price));
              break;
            case 'rating':
              products.sort((a, b) => b.rating.compareTo(a.rating));
              break;
            default: // newest
              products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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
                        ),
                      ),
                      // Product info
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product name
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Brand
                              Text(
                                product.brand,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  if (product.originalPrice >
                                      product.price) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'vi_VN',
                                        symbol: '₫',
                                        decimalDigits: 0,
                                      ).format(product.originalPrice),
                                      style: TextStyle(
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Rating
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber[700], size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
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
    );
  }
}
