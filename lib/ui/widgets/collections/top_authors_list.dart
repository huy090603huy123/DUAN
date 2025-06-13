import 'package:flutter/material.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../utils/enums/page_type_enum.dart';
import '../../../models/author.dart';

class TopAuthorsList extends StatelessWidget {
  final List<Author> authors;

  // SỬA LỖI: Cập nhật cú pháp constructor cho đúng chuẩn null safety.
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
        itemBuilder: (ctx, i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
          child: InkWell(
            onTap: () {
              Helper.navigateToPage(
                context: context,
                page: PageType.AUTHOR,
                arguments: authors[i].id,
              );
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  // Thêm errorBuilder để xử lý lỗi tải ảnh
                  onBackgroundImageError: (exception, stackTrace) {
                    // Bạn có thể log lỗi ở đây nếu cần
                  },
                  backgroundImage: NetworkImage(authors[i].imageUrl),
                  // Fallback trong trường hợp ảnh lỗi hoặc không có
                  child: (authors[i].imageUrl.isEmpty)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 5),
                Text(
                  "${authors[i].firstName}\n${authors[i].lastName}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}