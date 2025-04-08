import 'package:flutter/material.dart';
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                IndexedStack(
                  index: provider.selectedIndex,
                  children: [
                    // Trang chủ
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
                // Overlay tìm kiếm - hiển thị trên tất cả các tab
                if (provider.isSearching) const SearchResultsWidget(),
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
