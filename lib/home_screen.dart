import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:focusbadminton/providers/home_screen_provider.dart';
import 'package:focusbadminton/widgets/home/search_bar_widget.dart';
import 'package:focusbadminton/widgets/home/circular_menu_widget.dart';
import 'package:focusbadminton/widgets/home/new_products_widget.dart';
import 'package:focusbadminton/widgets/home/categories_grid_widget.dart';
import 'package:focusbadminton/widgets/home/brands_widget.dart';
import 'package:focusbadminton/widgets/home/search_results_widget.dart';
import 'package:focusbadminton/screens/category_screen.dart';
import 'package:focusbadminton/screens/cart_screen.dart';
import 'package:focusbadminton/screens/profile_screen.dart';
import 'package:focusbadminton/screens/notifications_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Phương thức để mở URL bản đồ
  Future<void> _launchMapUrl(String address) async {
    final Uri url = Uri.parse('https://maps.google.com/?q=$address');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Không thể mở $url');
      }
    } catch (e) {
      debugPrint('Lỗi khi mở bản đồ: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở bản đồ. Vui lòng thử lại sau.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Phương thức để hiển thị dialog thông tin
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[900]),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeScreenProvider(),
      child: Consumer<HomeScreenProvider>(
        builder: (context, provider, _) {
          // Kiểm tra trạng thái đăng nhập
          if (provider.shouldNavigateToLogin(context)) {
            return Container(); // Sẽ chuyển hướng đến trang đăng nhập
          }

          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(90),
              child: AppBar(
                backgroundColor: Colors.blue[900],
                elevation: 0,
                automaticallyImplyLeading: false, // Tắt nút back tự động
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // Logo
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 150,
                            maxWidth: 180,
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Search bar
                        const Expanded(
                          child: SearchBarWidget(),
                        ),
                        const SizedBox(width: 12),
                        // Nút theo dõi đơn hàng
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Hiển thị thông báo tính năng đang phát triển
                              _showInfoDialog(
                                context,
                                'Theo dõi đơn hàng',
                                'Tính năng đang được phát triển. Vui lòng quay lại sau!',
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            splashColor: Colors.amber.withAlpha(80),
                            highlightColor: Colors.amber.withAlpha(40),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.amber.shade300,
                                    Colors.amber.shade600,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(50),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/box_icon.svg',
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nút hiển thị địa chỉ cửa hàng
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Hiển thị thông tin địa chỉ cửa hàng
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.blue[900]),
                                      const SizedBox(width: 8),
                                      const Text('Sân Cầu Lông Focus'),
                                    ],
                                  ),
                                  content: const Text(
                                      '18/10 Phan Văn Hớn, Xuân Thới Thượng, Hóc Môn, HCM'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Đóng'),
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.map),
                                      label: const Text('Xem bản đồ'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[900],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // Mở bản đồ Google Maps
                                        _launchMapUrl(
                                            '18/10 Phan Văn Hớn, Xuân Thới Thượng, Hóc Môn, HCM');
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            splashColor: Colors.blue.withAlpha(80),
                            highlightColor: Colors.blue.withAlpha(40),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade300,
                                    Colors.blue.shade600,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(50),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/location_icon.svg',
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: IndexedStack(
              index: provider.selectedIndex,
              children: [
                // Trang chủ
                Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          // Top circular menu
                          CircularMenuWidget(),

                          // New Products
                          NewProductsWidget(),

                          // Categories Grid
                          CategoriesGridWidget(),

                          // Brand section
                          BrandsWidget(),
                        ],
                      ),
                    ),
                    // Overlay tìm kiếm
                    if (provider.isSearching) const SearchResultsWidget(),
                  ],
                ),
                // Tab danh mục
                Consumer<HomeScreenProvider>(
                  builder: (context, provider, _) {
                    return CategoryScreen(
                      category: provider.selectedCategory,
                      filter: provider.categoryFilter,
                    );
                  },
                ),
                // Tab thông báo
                const NotificationsScreen(),
                // Tab giỏ hàng
                const CartScreen(),
                // Tab tài khoản
                const ProfileScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: provider.selectedIndex,
              onTap: (index) {
                provider.setSelectedIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue[900],
              unselectedItemColor: Colors.grey[600],
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category),
                  label: 'Danh mục',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Thông báo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: 'Giỏ hàng',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Tài khoản',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
