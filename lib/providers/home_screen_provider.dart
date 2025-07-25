import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusbadminton/auth/login_screen.dart';
import 'package:focusbadminton/models/product.dart';
import 'package:focusbadminton/services/product_service.dart';

class HomeScreenProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final TextEditingController searchController = TextEditingController();

  User? _user;
  String _searchQuery = '';
  bool _isSearching = false;
  int _selectedIndex = 0;

  // Category screen state
  String _selectedCategory = 'Tất cả';
  String? _categoryFilter;

  // Getters
  User? get user => _user;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  int get selectedIndex => _selectedIndex;
  String get selectedCategory => _selectedCategory;
  String? get categoryFilter => _categoryFilter;

  // Streams
  Stream<List<Product>> get newProducts => _productService.getNewProducts();
  Stream<List<Product>> get hotProducts => _productService.getHotProducts();
  Stream<List<Product>> get saleProducts => _productService.getSaleProducts();

  Stream<List<Product>> searchProducts() {
    return _productService.searchProducts(_searchQuery);
  }

  HomeScreenProvider() {
    _checkAuthState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;

    // Reset category và filter khi chuyển tab
    if (index != 1) {
      // Nếu không phải tab danh mục
      _selectedCategory = 'Tất cả';
      _categoryFilter = null;
    }

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    notifyListeners();
  }

  void toggleSearching(bool value) {
    _isSearching = value;
    if (!value) {
      _searchQuery = '';
      searchController.clear();
    }
    notifyListeners();
  }

  void clearSearch(BuildContext context) {
    searchController.clear();
    _searchQuery = '';
    _isSearching = false;
    FocusScope.of(context).unfocus();
    notifyListeners();
  }

  bool shouldNavigateToLogin(BuildContext context) {
    if (_user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return true;
    }
    return false;
  }

  // Phương thức để chuyển đến tab danh mục với category và filter
  void navigateToCategory(String category, {String? filter}) {
    _selectedCategory = category;
    _categoryFilter = filter;
    _selectedIndex = 1; // Chuyển đến tab danh mục
    notifyListeners();
  }
}
