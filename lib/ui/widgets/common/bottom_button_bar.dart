import 'package:flutter/material.dart';

class BottomButtonBar extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  // SỬA LỖI: Cập nhật cú pháp constructor cho đúng chuẩn null safety.
  const BottomButtonBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), // Thêm padding dưới để an toàn hơn
      child:
      // SỬA LỖI: FlatButton đã lỗi thời, thay bằng ElevatedButton
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: const Size(double.infinity, 50), // Đảm bảo nút chiếm toàn bộ chiều rộng
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            letterSpacing: 1.4,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}