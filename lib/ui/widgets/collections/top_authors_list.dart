import 'package:flutter/material.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../utils/enums/page_type_enum.dart';
import '../../../models/author.dart';

class TopAuthorsList extends StatelessWidget {
  final List<Author> authors;

  const TopAuthorsList({
    super.key,
    required this.authors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 135,
      child: authors.isEmpty
          ? Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
          child: const LinearProgressIndicator(),
        ),
      )
          : ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: authors.length,
        itemBuilder: (ctx, i) {
          final author = authors[i];
          // SỬA LỖI 1: Tạo một biến để kiểm tra imageUrl một cách an toàn
          final imageUrl = author.imageUrl;
          final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
            child: InkWell(
              onTap: () {
                Helper.navigateToPage(
                  context: context,
                  page: PageType.AUTHOR,
                  arguments: author.id,
                );
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade300, // Màu nền dự phòng
                    // SỬA LỖI 2: Chỉ tạo NetworkImage khi có URL hợp lệ
                    backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
                    // SỬA LỖI 3: Hiển thị Icon nếu không có ảnh
                    child: !hasImage
                        ? const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    )
                        : null,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    author.authorName, // Sử dụng getter cho gọn
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
