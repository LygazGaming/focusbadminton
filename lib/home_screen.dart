import 'package:focusbadminton/auth/auth_service.dart';
import 'package:focusbadminton/auth/login_screen.dart';
import 'package:focusbadminton/models/product.dart';
import 'package:focusbadminton/screens/cart_screen.dart';
import 'package:focusbadminton/screens/category_screen.dart';
import 'package:focusbadminton/screens/notification_screen.dart';
import 'package:focusbadminton/screens/product_detail_screen.dart';
import 'package:focusbadminton/screens/profile_screen.dart';
import 'package:focusbadminton/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.blue[900],
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 35,
                  ),
                  const SizedBox(width: 16),
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                        ),
                        onSubmitted: (value) {
                          // TODO: Implement search functionality
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right icons
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _signOut,
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/icons/box_icon.svg',
                    height: 24,
                    colorFilter:
                        ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/icons/location_icon.svg',
                    height: 24,
                    colorFilter:
                        ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/icons/qr_icon.svg',
                    height: 24,
                    colorFilter:
                        ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Trang chủ
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top circular menu
                Container(
                  color: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircularMenuItem(
                              Icons.menu, 'Danh mục', Colors.green[500]!,
                              onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CategoryScreen(category: 'Vợt'),
                              ),
                            );
                          }),
                          _buildCircularMenuItem(
                              Icons.new_releases, 'Hàng mới', Colors.orange,
                              isSpecial: true),
                          _buildCircularMenuItem(
                              Icons.article, 'Tin tức', Colors.green[500]!),
                          _buildCircularMenuItem(
                              Icons.support_agent, 'CSKH', Colors.blue[400]!),
                          _buildCircularMenuItem(Icons.location_on,
                              'Địa chỉ sân', Colors.grey[400]!),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircularMenuItem(Icons.local_fire_department,
                              'Deal', Colors.deepOrange,
                              isHotSale: true),
                          _buildCircularMenuItem(
                              Icons.flash_on, 'Flash Sale', Colors.amber[700]!),
                          _buildCircularMenuItem(
                              Icons.eco, 'Theo mùa', Colors.lightGreen[500]!),
                          _buildCircularMenuItem(
                              Icons.card_giftcard, 'Combo', Colors.red,
                              isCombo: true),
                          _buildCircularMenuItem(
                              Icons.menu_book, 'Cẩm nang', Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),

                // Flash deals section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Flash deals',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('11 : 11', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<List<Product>>(
                        stream: _productService.getSaleProducts(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final products = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: products.map((product) {
                                return Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: GestureDetector(
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
                                    child: Column(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: product.imageUrl,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                NumberFormat.currency(
                                                  locale: 'vi_VN',
                                                  symbol: '₫',
                                                  decimalDigits: 0,
                                                ).format(product.price),
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(product.name),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Categories Grid
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh mục',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final categories = [
                            {'name': 'Vợt', 'icon': Icons.sports_tennis},
                            {'name': 'Giày', 'icon': Icons.shopping_bag},
                            {'name': 'Túi', 'icon': Icons.backpack},
                            {'name': 'Phụ kiện', 'icon': Icons.settings},
                          ];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryScreen(
                                    category:
                                        categories[index]['name'] as String,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    categories[index]['icon'] as IconData,
                                    size: 40,
                                    color: Colors.blue[900],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    categories[index]['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Brand section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thương hiệu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/yonex.png',
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Other screens
          const CategoryScreen(category: 'Tất cả'),
          const CartScreen(),
          const NotificationScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Danh mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }

  Widget _buildCircularMenuItem(IconData icon, String label, Color color,
      {bool isSpecial = false,
      bool isHotSale = false,
      bool isCombo = false,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              if (isSpecial)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              if (isHotSale)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              if (isCombo)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
