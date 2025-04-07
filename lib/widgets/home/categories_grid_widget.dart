import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusbadminton/providers/home_screen_provider.dart';

class CategoriesGridWidget extends StatelessWidget {
  const CategoriesGridWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeScreenProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh mục sản phẩm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  provider.setSelectedIndex(1); // Chuyển đến tab danh mục
                },
                child: Text(
                  'Xem thêm',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final categories = [
                {
                  'name': 'Vợt',
                  'icon': Icons.sports_tennis,
                  'color': Colors.blue[700]
                },
                {
                  'name': 'Áo',
                  'icon': Icons.shopping_bag,
                  'color': Colors.green[600]
                },
                {
                  'name': 'Balo',
                  'icon': Icons.backpack,
                  'color': Colors.orange[700]
                },
                {
                  'name': 'Phụ kiện',
                  'icon': Icons.settings,
                  'color': Colors.purple[600]
                },
              ];

              return GestureDetector(
                onTap: () {
                  provider
                      .navigateToCategory(categories[index]['name'] as String);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (categories[index]['color'] as Color?)
                                ?.withOpacity(0.7) ??
                            Colors.blue[700]!.withOpacity(0.7),
                        (categories[index]['color'] as Color?)
                                ?.withOpacity(0.9) ??
                            Colors.blue[900]!.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        categories[index]['icon'] as IconData,
                        size: 45,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        categories[index]['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }
}
