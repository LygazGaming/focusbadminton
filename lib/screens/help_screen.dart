import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ giúp'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blue[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chúng tôi luôn sẵn sàng hỗ trợ bạn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chọn một trong các tùy chọn bên dưới để nhận trợ giúp',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Liên hệ với chúng tôi',
              children: [
                _buildContactItem(
                  context,
                  icon: Icons.phone,
                  title: 'Hotline',
                  subtitle: '0905353230',
                  onTap: () => _launchUrl('tel:0905353230'),
                ),
                _buildContactItem(
                  context,
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: 'longa4609@gmail.com',
                  onTap: () => _launchUrl('mailto:longa4609@gmail.com'),
                ),
                _buildContactItem(
                  context,
                  icon: Icons.chat_bubble,
                  title: 'Zalo',
                  subtitle: '0905353230',
                  onTap: () => _launchUrl('https://zalo.me/0905353230'),
                ),
                _buildContactItem(
                  context,
                  icon: Icons.facebook,
                  title: 'Facebook',
                  subtitle: 'Focus Badminton',
                  onTap: () =>
                      _launchUrl('https://www.facebook.com/LongSeaGamer'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Câu hỏi thường gặp',
              children: [
                _buildFaqItem(
                  context,
                  question: 'Làm thế nào để đặt hàng?',
                  answer:
                      'Để đặt hàng, bạn chỉ cần chọn sản phẩm, thêm vào giỏ hàng và tiến hành thanh toán. Bạn có thể thanh toán bằng nhiều phương thức khác nhau như tiền mặt khi nhận hàng, chuyển khoản ngân hàng, hoặc ví điện tử.',
                ),
                _buildFaqItem(
                  context,
                  question: 'Chính sách đổi trả như thế nào?',
                  answer:
                      'Chúng tôi chấp nhận đổi trả trong vòng 7 ngày kể từ ngày nhận hàng nếu sản phẩm còn nguyên vẹn, không có dấu hiệu đã qua sử dụng và còn đầy đủ bao bì, nhãn mác. Vui lòng liên hệ với chúng tôi trước khi gửi trả sản phẩm.',
                ),
                _buildFaqItem(
                  context,
                  question: 'Thời gian giao hàng là bao lâu?',
                  answer:
                      'Thời gian giao hàng thông thường là 2-3 ngày đối với khu vực nội thành và 3-5 ngày đối với khu vực ngoại thành. Thời gian có thể thay đổi tùy thuộc vào địa điểm và tình trạng kho hàng.',
                ),
                _buildFaqItem(
                  context,
                  question: 'Làm thế nào để theo dõi đơn hàng?',
                  answer:
                      'Bạn có thể theo dõi đơn hàng bằng cách đăng nhập vào tài khoản và vào mục "Đơn hàng của tôi". Tại đây, bạn có thể xem trạng thái đơn hàng và thông tin vận chuyển.',
                ),
                _buildFaqItem(
                  context,
                  question: 'Tôi có thể hủy đơn hàng không?',
                  answer:
                      'Bạn có thể hủy đơn hàng trước khi đơn hàng được xác nhận. Sau khi đơn hàng đã được xác nhận, vui lòng liên hệ với chúng tôi qua hotline hoặc email để được hỗ trợ.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Hướng dẫn sử dụng',
              children: [
                _buildGuideItem(
                  context,
                  title: 'Hướng dẫn đặt hàng',
                  onTap: () {
                    // Hiển thị hướng dẫn đặt hàng
                    _showGuideDialog(
                      context,
                      'Hướng dẫn đặt hàng',
                      [
                        'Bước 1: Chọn sản phẩm bạn muốn mua',
                        'Bước 2: Nhấn nút "Thêm vào giỏ hàng"',
                        'Bước 3: Vào giỏ hàng và nhấn "Thanh toán"',
                        'Bước 4: Điền thông tin giao hàng',
                        'Bước 5: Chọn phương thức thanh toán',
                        'Bước 6: Xác nhận đơn hàng',
                      ],
                    );
                  },
                ),
                _buildGuideItem(
                  context,
                  title: 'Hướng dẫn thanh toán',
                  onTap: () {
                    // Hiển thị hướng dẫn thanh toán
                    _showGuideDialog(
                      context,
                      'Hướng dẫn thanh toán',
                      [
                        'Thanh toán khi nhận hàng (COD): Bạn sẽ thanh toán cho nhân viên giao hàng khi nhận được sản phẩm.',
                        'Thanh toán PayPal: Bạn sẽ thanh toán trực tuyến bằng PayPal.',
                      ],
                    );
                  },
                ),
                _buildGuideItem(
                  context,
                  title: 'Hướng dẫn đổi trả',
                  onTap: () {
                    // Hiển thị hướng dẫn đổi trả
                    _showGuideDialog(
                      context,
                      'Hướng dẫn đổi trả',
                      [
                        'Bước 1: Liên hệ với chúng tôi qua hotline hoặc email trong vòng 7 ngày kể từ ngày nhận hàng.',
                        'Bước 2: Cung cấp mã đơn hàng và lý do đổi trả.',
                        'Bước 3: Chúng tôi sẽ hướng dẫn bạn cách gửi trả sản phẩm.',
                        'Bước 4: Sau khi nhận được sản phẩm trả lại, chúng tôi sẽ kiểm tra và xử lý yêu cầu của bạn.',
                        'Bước 5: Hoàn tiền hoặc gửi sản phẩm thay thế cho bạn.',
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[900]),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showGuideDialog(
    BuildContext context,
    String title,
    List<String> steps,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: steps
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(entry.value),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
