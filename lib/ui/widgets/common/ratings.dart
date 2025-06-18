import 'package:flutter/material.dart';

class Ratings extends StatelessWidget {
  final int rating;
  final double itemSize;
  // Callback để xử lý khi người dùng chọn một mức đánh giá mới
  final Function(double)? onRatingUpdate;

  const Ratings({
    super.key,
    required this.rating,
    this.itemSize = 20, // Kích thước mặc định
    this.onRatingUpdate, // Tham số tùy chọn
  });

  @override
  Widget build(BuildContext context) {
    // Luôn hiển thị 5 sao
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            // Nếu có hàm onRatingUpdate được cung cấp, gọi nó
            if (onRatingUpdate != null) {
              onRatingUpdate!(index + 1.0);
            }
          },
          child: Icon(
            // Hiển thị sao đầy nếu index nhỏ hơn mức rating, ngược lại hiển thị sao rỗng
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.yellow[800],
            size: itemSize,
          ),
        );
      }),
    );
  }
}
