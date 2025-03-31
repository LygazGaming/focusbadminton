import 'package:flutter/material.dart';
import 'package:focusbadminton/models/product.dart';
import 'package:focusbadminton/screens/product_detail_screen.dart';
import 'package:focusbadminton/services/product_service.dart';
import 'package:focusbadminton/widgets/button.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartItem {
  final String productId;
  final int quantity;
  Product? product;

  CartItem({
    required this.productId,
    required this.quantity,
    this.product,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ProductService _productService = ProductService();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    // TODO: Load cart items from local storage or backend
    setState(() {
      _isLoading = false;
    });
  }

  double get _totalAmount {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.product?.price ?? 0) * item.quantity,
    );
  }

  void _updateQuantity(String productId, int newQuantity) {
    setState(() {
      final index =
          _cartItems.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        _cartItems[index] = CartItem(
          productId: productId,
          quantity: newQuantity,
          product: _cartItems[index].product,
        );
      }
    });
  }

  void _removeItem(String productId) {
    setState(() {
      _cartItems.removeWhere((item) => item.productId == productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Giỏ hàng trống',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bạn chưa có sản phẩm nào trong giỏ hàng',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        label: 'Tiếp tục mua sắm',
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return FutureBuilder<Product?>(
                            future:
                                _productService.getProductById(item.productId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final product = snapshot.data!;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
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
                                child: Row(
                                  children: [
                                    // Product image
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailScreen(
                                              productId: product.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                            left: Radius.circular(8),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                            left: Radius.circular(8),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: product.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
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
                                            Text(
                                              product.brand,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              NumberFormat.currency(
                                                locale: 'vi_VN',
                                                symbol: '₫',
                                                decimalDigits: 0,
                                              ).format(product.price),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Quantity controls
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.remove),
                                                  onPressed: item.quantity > 1
                                                      ? () {
                                                          _updateQuantity(
                                                            product.id,
                                                            item.quantity - 1,
                                                          );
                                                        }
                                                      : null,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    item.quantity.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: item.quantity <
                                                          product.stock
                                                      ? () {
                                                          _updateQuantity(
                                                            product.id,
                                                            item.quantity + 1,
                                                          );
                                                        }
                                                      : null,
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () {
                                                    _removeItem(product.id);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Bottom bar with total and checkout button
                    Container(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tổng cộng:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'vi_VN',
                                    symbol: '₫',
                                    decimalDigits: 0,
                                  ).format(_totalAmount),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomButton(
                            label: 'Thanh toán',
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            onPressed: () {
                              // TODO: Implement checkout functionality
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
