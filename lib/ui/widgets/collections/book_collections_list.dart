import 'package:flutter/material.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../utils/enums/page_type_enum.dart';
import '../../../models/book.dart';

class BookCollectionList extends StatelessWidget {
  final List<Book> books;

  // SỬA LỖI: Cập nhật cú pháp constructor cho đúng chuẩn null safety.
  // - Bỏ `Key key` và thay bằng `super.key`.
  // - Bỏ `@required` và thay bằng từ khóa `required`.
  const BookCollectionList({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (ctx, i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
          child: InkWell(
            onTap: () {
              Helper.navigateToPage(
                context: context,
                page: PageType.BOOK,
                arguments: books[i].id,
              );
            },
            child: Card(
              elevation: 3,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: 140,
                child: Image.network(
                  books[i].imageUrl,
                  fit: BoxFit.fill,
                  // Thêm errorBuilder để xử lý lỗi tải ảnh
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.book); // Hiển thị icon sách nếu có lỗi
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
