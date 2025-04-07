import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusbadminton/models/product.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isLoading = true;
  List<Product> _products = [];
  List<Product> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    _loadProducts();
  }

  // Khởi tạo local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
  }

  // Tải danh sách sản phẩm
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromMap(data, doc.id);
      }).toList();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hiển thị thông báo local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'admin_channel',
      'Admin Notifications',
      channelDescription: 'Thông báo từ trang quản trị',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      0, // ID của thông báo
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Gửi thông báo về sản phẩm mới
  Future<void> _sendNotification() async {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một sản phẩm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Tạo batch để gửi nhiều thông báo cùng lúc
      final batch = _firestore.batch();

      // Tạo thông báo cho từng sản phẩm
      for (final product in _selectedProducts) {
        final notificationRef =
            _firestore.collection('admin_notifications').doc();
        batch.set(notificationRef, {
          'type': 'new_product',
          'title': 'Sản phẩm mới',
          'body': 'Đã có sản phẩm mới: ${product.name}',
          'data': {
            'product_id': product.id,
            'product_name': product.name,
            'product_image': product.imageUrl,
            'product_price': product.price,
          },
          'sentAt': FieldValue.serverTimestamp(),
          'status': 'pending', // Trạng thái chờ xử lý
        });
      }

      // Thực hiện batch
      await batch.commit();

      // Hiển thị thông báo local cho sản phẩm đầu tiên
      if (_selectedProducts.isNotEmpty) {
        final product = _selectedProducts[0];
        await _showLocalNotification(
          title: 'Sản phẩm mới',
          body: 'Đã có sản phẩm mới: ${product.name}',
          payload: '{"product_id":"${product.id}"}',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi thông báo thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset danh sách sản phẩm đã chọn
        setState(() {
          _selectedProducts = [];
        });
      }
    } catch (e) {
      print('Error sending notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi thông báo: ${e.toString()}'),
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

  // Chọn/bỏ chọn sản phẩm
  void _toggleProductSelection(Product product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi thông báo sản phẩm mới'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Chọn sản phẩm để gửi thông báo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: _products.isEmpty
                      ? Center(
                          child: Text(
                            'Không có sản phẩm nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            final isSelected =
                                _selectedProducts.contains(product);

                            return CheckboxListTile(
                              title: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Giá: ${product.price.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              secondary: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[400],
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                    ),
                              value: isSelected,
                              onChanged: (value) {
                                _toggleProductSelection(product);
                              },
                              activeColor: Colors.blue[900],
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Đã chọn ${_selectedProducts.length} sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _selectedProducts.isEmpty
                            ? null
                            : _sendNotification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Gửi thông báo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
