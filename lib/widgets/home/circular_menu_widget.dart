import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:focusbadminton/providers/home_screen_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircularMenuWidget extends StatelessWidget {
  const CircularMenuWidget({super.key});

  // Phương thức để hiển thị dialog thông tin
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  // Phương thức để hiển thị danh sách địa chỉ sân
  void _showCourtLocations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Địa chỉ sân cầu lông',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildCourtLocationItem(
                        'Sân Cầu Lông Focus',
                        '18/10 Phan Văn Hớn, Xuân Thới Thượng, Hóc Môn, Hồ Chí Minh 700000, Việt Nam',
                        '0905353230',
                        context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Phương thức để hiển thị thông tin liên hệ CSKH
  void _showCustomerService(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Liên hệ hỗ trợ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildContactItem(
              Icons.phone,
              'Hotline',
              '0905353230',
              () => _launchUrl('tel:0905353230'),
            ),
            const Divider(),
            _buildContactItem(
              Icons.email,
              'Email',
              'longa4609@gmail.com',
              () => _launchUrl('mailto:longa4609@gmail.com'),
            ),
            const Divider(),
            _buildContactItem(
              Icons.chat_bubble_outline,
              'Zalo',
              '0905353230',
              () => _launchUrl('https://zalo.me/0905353230'),
            ),
            const Divider(),
            _buildContactItem(
              Icons.facebook,
              'Facebook',
              'Focus Badminton',
              () => _launchUrl('https://www.facebook.com'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Phương thức để mở URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  // Widget hiển thị thông tin liên hệ
  Widget _buildContactItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    // Widget cho biểu tượng
    Widget leadingWidget;

    // Sử dụng SVG cho Zalo và Facebook
    if (title == 'Zalo') {
      leadingWidget = SvgPicture.asset(
        'assets/icons/zalo.svg',
        width: 30,
        height: 30,
      );
    } else if (title == 'Facebook') {
      leadingWidget = SvgPicture.asset(
        'assets/icons/facebook.svg',
        width: 30,
        height: 30,
      );
    } else {
      // Sử dụng biểu tượng mặc định cho các trường hợp khác
      leadingWidget = Icon(icon, color: Colors.blue[900]);
    }

    return ListTile(
      leading: leadingWidget,
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  // Widget hiển thị thông tin sân cầu lông
  Widget _buildCourtLocationItem(
      String name, String address, String phone, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Xem bản đồ'),
                  onPressed: () {
                    _launchUrl('https://maps.google.com/?q=$address');
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Gọi'),
                  onPressed: () {
                    _launchUrl('tel:$phone');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularMenuItem(
                Icons.menu,
                'Danh mục',
                Colors.green[500]!,
                onTap: () {
                  Provider.of<HomeScreenProvider>(context, listen: false)
                      .navigateToCategory('Tất cả');
                },
              ),
              _buildCircularMenuItem(
                Icons.new_releases,
                'Hàng mới',
                Colors.orange,
                isSpecial: true,
                onTap: () {
                  Provider.of<HomeScreenProvider>(context, listen: false)
                      .navigateToCategory('Mới');
                },
              ),
              _buildCircularMenuItem(
                Icons.article,
                'Tin tức',
                Colors.green[500]!,
                onTap: () {
                  _showInfoDialog(
                    context,
                    'Tin tức',
                    'Tính năng đang được phát triển. Vui lòng quay lại sau!',
                  );
                },
              ),
              _buildCircularMenuItem(
                Icons.support_agent,
                'CSKH',
                Colors.blue[400]!,
                onTap: () {
                  _showCustomerService(context);
                },
              ),
              _buildCircularMenuItem(
                Icons.location_on,
                'Địa chỉ sân',
                Colors.grey[400]!,
                onTap: () {
                  _showCourtLocations(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularMenuItem(
                Icons.local_fire_department,
                'Deal',
                Colors.deepOrange,
                isHotSale: true,
                onTap: () {
                  Provider.of<HomeScreenProvider>(context, listen: false)
                      .navigateToCategory('Tất cả', filter: 'deal');
                },
              ),
              _buildCircularMenuItem(
                Icons.flash_on,
                'Flash Sale',
                Colors.amber[700]!,
                onTap: () {
                  Provider.of<HomeScreenProvider>(context, listen: false)
                      .navigateToCategory('Tất cả', filter: 'flash_sale');
                },
              ),
              _buildCircularMenuItem(
                Icons.eco,
                'Theo mùa',
                Colors.lightGreen[500]!,
                onTap: () {
                  Provider.of<HomeScreenProvider>(context, listen: false)
                      .navigateToCategory('Tất cả', filter: 'seasonal');
                },
              ),
              _buildCircularMenuItem(
                Icons.card_giftcard,
                'Combo',
                Colors.red,
                isCombo: true,
                onTap: () {
                  Provider.of<HomeScreenProvider>(context, listen: false)
                      .navigateToCategory('Tất cả', filter: 'combo');
                },
              ),
              _buildCircularMenuItem(
                Icons.menu_book,
                'Cẩm nang',
                Colors.purple,
                onTap: () {
                  _showInfoDialog(
                    context,
                    'Cẩm nang cầu lông',
                    'Tính năng đang được phát triển. Vui lòng quay lại sau!',
                  );
                },
              ),
            ],
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                if (isSpecial)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isHotSale)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'H',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isCombo)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'C',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
