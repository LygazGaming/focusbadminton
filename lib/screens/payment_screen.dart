import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/cart.dart';

class PaymentScreen extends StatefulWidget {
  final Cart cart;

  const PaymentScreen({
    super.key,
    required this.cart,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tạo danh sách sản phẩm cho PayPal
      final items = widget.cart.items.map((item) {
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
        amount: widget.cart.total,
        currency: 'USD',
        items: items,
      );

      // Xử lý thanh toán PayPal
      try {
        // Kiểm tra mounted trước khi gọi processPayPalPayment
        if (!mounted) return;

        await _paymentService.processPayPalPayment(
          context: context,
          amount: widget.cart.total / 25000, // Chuyển đổi VND sang USD
          currency: 'USD',
          items: items,
          orderId: orderId,
        );

        // Kiểm tra mounted trước khi hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Kiểm tra mounted trước khi hiển thị thông báo lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng quan đơn hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.cart.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.product.name} x ${item.quantity}'),
                              Text(
                                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${widget.cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[900],
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Thanh toán với PayPal',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
