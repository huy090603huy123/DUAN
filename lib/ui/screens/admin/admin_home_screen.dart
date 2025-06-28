import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/members_provider.dart';
import '../../../ui/screens/login_screen.dart';
import 'admin_requests_screen.dart';
import 'manage_authors_screen.dart';
import 'manage_books_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // THÊM MỚI: Hàm xử lý đăng xuất
  Future<void> _logout(BuildContext context) async {
    try {
      // Gọi hàm signOut từ provider
      await Provider.of<MembersProvider>(context, listen: false).signOut();

      // Điều hướng về màn hình đăng nhập và xóa hết các màn hình cũ
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Xử lý nếu có lỗi xảy ra trong quá trình đăng xuất
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).primaryColor,
        // THÊM MỚI: Nút đăng xuất
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        childAspectRatio: 8.0 / 9.0,
        children: <Widget>[
          _buildCard(
            context,
            'Manage Books',
            Icons.book,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageBooksScreen()),
              );
            },
          ),
          _buildCard(
            context,
            'Manage Authors',
            Icons.person,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageAuthorsScreen()),
              );
            },
          ),
          _buildCard(
            context,
            'Duyệt Yêu Cầu',
            Icons.checklist_rtl, // Icon phù hợp cho việc duyệt
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminRequestsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}