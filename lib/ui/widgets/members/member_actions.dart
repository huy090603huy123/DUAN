import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/utils/enums/page_type_enum.dart';

import '../../../providers/members_provider.dart';
import '../../../ui/screens/login_screen.dart'; // THÊM MỚI: import màn hình Login
import '../../../utils/helper.dart';
import '../common/alert_dialog.dart';

class MemberActions extends StatefulWidget {
  const MemberActions({super.key});

  @override
  State<MemberActions> createState() => _MemberActionsState();
}

class _MemberActionsState extends State<MemberActions> {
  String _action = '';
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _resetAction() {
    setState(() {
      _action = '';
      _passwordController.clear();
      _confirmPasswordController.clear();
      _emailController.clear();
      _bioController.clear();
      _ageController.clear();
    });
  }

  // --- BẮT ĐẦU THAY ĐỔI ---

  // THÊM MỚI: Hàm xử lý đăng xuất
  Future<void> _logout() async {
    // Gọi trực tiếp hàm signOut của Firebase
    await FirebaseAuth.instance.signOut();

    // Kiểm tra xem widget còn tồn tại không trước khi điều hướng
    if (mounted) {
      // Điều hướng về màn hình Login và xóa tất cả các màn hình trước đó
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  // --- KẾT THÚC THAY ĐỔI ---

  Widget confirmCancelRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _resetAction,
          child: const Text(
            "Cancel",
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.green,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final memberProvider =
            Provider.of<MembersProvider>(context, listen: false);

            if (_passwordController.text.isNotEmpty &&
                _passwordController.text != _confirmPasswordController.text) {
              showDialog(
                context: context,
                builder: (ctx) =>
                const AlertDialogBox(message: "Passwords don't match"),
              );
              return;
            }

            bool updated = await memberProvider.changeProfileData(
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              password: _passwordController.text.trim().isEmpty
                  ? null
                  : _passwordController.text.trim(),
              bio: _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
              age: _ageController.text.trim().isEmpty
                  ? null
                  : int.tryParse(_ageController.text.trim()),
            );

            if (mounted) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialogBox(
                  message: updated
                      ? "Data updated successfully"
                      : "Failed to update data",
                ),
              );
            }
            _resetAction();
          },
          child: const Text(
            "Confirm",
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget changePassword() {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextFormField(
          controller: _passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            hintText: "New Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _confirmPasswordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock),
            hintText: "Confirm Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        confirmCancelRow(),
      ],
    );
  }

  Widget changeEmail() {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email),
            hintText: "New Email",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        confirmCancelRow(),
      ],
    );
  }

  Widget changeBio() {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextFormField(
          controller: _bioController,
          keyboardType: TextInputType.text,
          maxLines: 5,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.edit),
            hintText: "New Bio",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        confirmCancelRow(),
      ],
    );
  }

  Widget changeAge() {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          maxLines: 1,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.leaderboard_outlined),
            hintText: "New Age",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        confirmCancelRow(),
      ],
    );
  }

  Widget buildOptionButton({
    required VoidCallback onTap,
    required String action,
    Color actionColor = Colors.black,
    Color iconColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: Helper.hPadding, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              action,
              style: TextStyle(fontSize: 18, color: actionColor),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: iconColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildActionWidget() {
    switch (_action) {
      case "bio":
        return changeBio();
      case "pass":
        return changePassword();
      case "email":
        return changeEmail();
      case "age":
        return changeAge();
      default:
        return Column(
          children: [
            const SizedBox(height: 5),
            buildOptionButton(
              iconColor: Theme.of(context).primaryColor,
              onTap: () => setState(() => _action = "pass"),
              action: "Change password",
            ),
            Divider(height: 10, thickness: 1.3, color: Colors.grey[300]),
            buildOptionButton(
              iconColor: Theme.of(context).primaryColor,
              onTap: () => setState(() => _action = "email"),
              action: "Change email",
            ),
            Divider(height: 10, thickness: 1.3, color: Colors.grey[300]),
            buildOptionButton(
              iconColor: Theme.of(context).primaryColor,
              onTap: () => setState(() => _action = "bio"),
              action: "Change bio",
            ),
            Divider(height: 10, thickness: 1.3, color: Colors.grey[300]),
            buildOptionButton(
              iconColor: Theme.of(context).primaryColor,
              onTap: () => setState(() => _action = "age"),
              action: "Change age",
            ),
            Divider(height: 10, thickness: 1.3, color: Colors.grey[300]),
            buildOptionButton(
              iconColor: Theme.of(context).primaryColor,
              onTap: () => Helper.navigateToPage(
                  context: context, page: PageType.MEMBERPREFS),
              action: "Change preferences",
            ),
            // --- BẮT ĐẦU THAY ĐỔI ---
            Divider(height: 10, thickness: 1.3, color: Colors.grey[300]),
            // THÊM MỚI: Nút đăng xuất
            buildOptionButton(
              actionColor: Colors.red, // Làm cho nút có màu đỏ để gây chú ý
              iconColor: Colors.red,
              onTap: _logout, // Gọi hàm _logout khi nhấn
              action: "Logout",
            ),
            // --- KẾT THÚC THAY ĐỔI ---
            const SizedBox(height: 5),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding, vertical: 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildActionWidget(),
      ),
    );
  }
}