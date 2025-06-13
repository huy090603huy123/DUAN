import 'package:flutter/material.dart';

import '../../../models/book.dart';
import '../../widgets/books/books_list.dart';

class AuthorBookScreen extends StatelessWidget {
  const AuthorBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI:
    // 1. Sử dụng toán tử `?` để truy cập `settings` một cách an toàn, phòng trường hợp ModalRoute.of(context) trả về null.
    // 2. Ép kiểu (cast) `arguments` thành `List<Book>?` để trình biên dịch biết kiểu dữ liệu mong đợi.
    final books = ModalRoute.of(context)?.settings.arguments as List<Book>?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Published Books"),
      ),
      // SỬA LỖI:
      // 3. Sử dụng toán tử `?? []` để cung cấp một danh sách rỗng mặc định nếu `books` là null.
      // Điều này đảm bảo BooksList luôn nhận được một List hợp lệ.
      body: BooksList(books: books ?? []),
    );
  }
}
