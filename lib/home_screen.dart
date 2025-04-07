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
import 'package:focusbadminton/screens/notification_screen.dart';
import 'package:focusbadminton/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
              preferredSize: const Size.fromHeight(70),
              child: AppBar(
                backgroundColor: Colors.blue[900],
                elevation: 0,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo.png',
                          height: 45,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),
                        // Search bar
                        const Expanded(
                          child: SearchBarWidget(),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/box_icon.svg',
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                                Colors.amber, BlendMode.srcIn),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/location_icon.svg',
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                                Colors.amber, BlendMode.srcIn),
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
                const NotificationScreen(),
                const CartScreen(),
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
