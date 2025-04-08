import 'package:flutter/material.dart';
import 'package:focusbadminton/services/payment_service.dart';
import 'package:focusbadminton/services/cart_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PaymentService _paymentService = PaymentService();
  final CartService _cartService = CartService();
  bool _isLoading = false;
  String _selectedPaymentMethod = 'paypal';
  final _formKey = GlobalKey<FormState>();

  // Thông tin giao hàng
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<CartItem>>(
              stream: _cartService.getCartItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  );
                }

                final cartItems = snapshot.data ?? [];
                if (cartItems.isEmpty) {
                  return const Center(
                    child: Text('Giỏ hàng trống'),
                  );
                }

                // Tính tổng tiền
                double total = 0;
                for (var item in cartItems) {
                  total += item.product.price * item.quantity;
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Thông tin giao hàng
                          const Text(
                            'Thông tin giao hàng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Họ tên',
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập họ tên';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Số điện thoại',
                                      prefixIcon: Icon(Icons.phone),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập số điện thoại';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: const InputDecoration(
                                      labelText: 'Địa chỉ',
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                    maxLines: 2,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập địa chỉ';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _noteController,
                                    decoration: const InputDecoration(
                                      labelText: 'Ghi chú (tùy chọn)',
                                      prefixIcon: Icon(Icons.note),
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tổng quan đơn hàng
                          const Text(
                            'Tổng quan đơn hàng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...cartItems.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.product.name} x ${item.quantity}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            NumberFormat.currency(
                                              locale: 'vi_VN',
                                              symbol: '₫',
                                              decimalDigits: 0,
                                            ).format(item.product.price *
                                                item.quantity),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Tổng cộng',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'vi_VN',
                                          symbol: '₫',
                                          decimalDigits: 0,
                                        ).format(total),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Phương thức thanh toán
                          const Text(
                            'Phương thức thanh toán',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.network(
                                        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/PayPal.svg/1200px-PayPal.svg.png',
                                        width: 80,
                                        height: 40,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(width: 8),
                                      const Flexible(
                                        child: Text(
                                          'PayPal',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: 'paypal',
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethod = value!;
                                    });
                                  },
                                ),
                                RadioListTile<String>(
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.money,
                                        color: Colors.green[700],
                                        size: 32,
                                      ),
                                      const SizedBox(width: 8),
                                      const Flexible(
                                        child: Text(
                                          'Thanh toán khi nhận hàng',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: 'cod',
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethod = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Nút thanh toán
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _processPayment(cartItems, total);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue[900],
                            ),
                            child: const Text(
                              'Xác nhận thanh toán',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _processPayment(List<CartItem> cartItems, double total) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Chuẩn bị thông tin giao hàng
      final deliveryInfo = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'note': _noteController.text,
      };

      // Chuyển đổi các sản phẩm thành định dạng cho PayPal
      final items = cartItems.map((item) {
        // Đảm bảo tên sản phẩm không quá dài (PayPal giới hạn 127 ký tự)
        String productName = item.product.name;
        if (productName.length > 120) {
          productName = "${productName.substring(0, 117)}...";
        }

        return {
          'name': productName,
          'quantity': item.quantity,
          'price': item.product.price.toString(),
        };
      }).toList();

      // Tạo đơn hàng mới
      final orderId = await _paymentService.createOrder(
        amount: total,
        currency: 'VND',
        items: items,
        deliveryInfo: deliveryInfo,
      );

      // Cập nhật phương thức thanh toán
      await _firestore.collection('orders').doc(orderId).update({
        'paymentMethod': _selectedPaymentMethod,
      });

      if (_selectedPaymentMethod == 'paypal') {
        if (!mounted) return;

        // Kiểm tra lại mounted trước khi xử lý thanh toán
        try {
          await _paymentService.processPayPalPayment(
            context: context,
            amount: total / 25000, // Chuyển đổi VND sang USD
            currency: 'USD',
            items: items,
            orderId: orderId,
          );

          // Xóa giỏ hàng nếu thanh toán PayPal thành công
          await _cartService.clearCart();

          // Hiển thị thông báo nếu vẫn còn mounted
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thanh toán thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            // Quay về trang chủ
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        } catch (paypalError) {
          if (!mounted) return;

          // Hiển thị thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi thanh toán PayPal: ${paypalError.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (_selectedPaymentMethod == 'cod') {
        // Cập nhật đơn hàng cho thanh toán khi nhận hàng (COD)
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'processing', // Trạng thái đang xử lý
          'paymentStatus': 'pending', // Chưa thanh toán
        });

        // Xóa giỏ hàng
        await _cartService.clearCart();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Đặt hàng thành công! Chúng tôi sẽ liên hệ với bạn sớm.'),
              backgroundColor: Colors.green,
            ),
          );

          // Quay về trang chủ
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    } catch (e) {
      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
