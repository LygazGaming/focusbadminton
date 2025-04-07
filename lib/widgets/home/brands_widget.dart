import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusbadminton/providers/home_screen_provider.dart';

class BrandsWidget extends StatelessWidget {
  const BrandsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeScreenProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thương hiệu hàng đầu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBrandCard('assets/images/yonex.png', 'Yonex', onTap: () {
                  // Chuyển sang tab danh mục với thương hiệu Yonex
                  provider.navigateToCategory('Tất cả', filter: 'brand_yonex');
                }),
                _buildBrandCard('assets/images/lining.jpg', 'Lining',
                    onTap: () {
                  // Chuyển sang tab danh mục với thương hiệu Lining
                  provider.navigateToCategory('Tất cả', filter: 'brand_lining');
                }),
                _buildBrandCard('assets/images/victor.jpg', 'Victor',
                    onTap: () {
                  // Chuyển sang tab danh mục với thương hiệu Victor
                  provider.navigateToCategory('Tất cả', filter: 'brand_victor');
                }),
                _buildBrandCard('assets/images/kawasaki.png', 'Kawasaki',
                    onTap: () {
                  // Chuyển sang tab danh mục với thương hiệu Kawasaki
                  provider.navigateToCategory('Tất cả',
                      filter: 'brand_kawasaki');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(String imagePath, String name, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                imagePath,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
