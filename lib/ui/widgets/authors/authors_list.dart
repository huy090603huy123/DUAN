import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/publishes_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../utils/enums/page_type_enum.dart';
import '../../../models/author.dart';
import '../common/ratings.dart';

class AuthorsList extends StatelessWidget {
  final String searchTerm;

  // SỬA LỖI: Cập nhật cú pháp constructor, yêu cầu 'searchTerm' và sử dụng super.key.
  const AuthorsList({super.key, required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách authors và lọc nó một cách an toàn.
    final List<Author> authors = Provider.of<PublishesProvider>(context, listen: false)
        .authors
        .where((author) {
      // Cải thiện logic tìm kiếm: không phân biệt chữ hoa chữ thường và xử lý null.
      final searchTermLower = searchTerm.toLowerCase();
      final firstNameLower = author.firstName.toLowerCase();
      final lastNameLower = author.lastName.toLowerCase();
      return firstNameLower.contains(searchTermLower) || lastNameLower.contains(searchTermLower);
    }).toList();

    return ListView.separated(
      itemCount: authors.length,
      separatorBuilder: (ctx, i) => const Divider(
        thickness: 1,
        height: 36,
      ),
      itemBuilder: (ctx, i) => InkWell(
        onTap: () {
          Helper.navigateToPage(
            context: context,
            page: PageType.AUTHOR,
            arguments: authors[i].id,
          );
        },
        child: AuthorsListItem(
          authorAge: authors[i].age,
          authorName: "${authors[i].firstName} ${authors[i].lastName}",
          authorRating: authors[i].rating,
          authorImageUrl: authors[i].imageUrl,
        ),
      ),
    );
  }
}

class AuthorsListItem extends StatelessWidget {
  // SỬA LỖI: Cập nhật cú pháp constructor để sử dụng 'required' và 'super.key'.
  const AuthorsListItem({
    super.key,
    required this.authorAge,
    required this.authorRating,
    required this.authorName,
    required this.authorImageUrl,
  });

  final int authorAge;
  final int authorRating;
  final String authorName;
  final String authorImageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
      child: Row(
        children: [
          //Avatar
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(authorImageUrl),
            backgroundColor: Colors.grey.shade200, // Thêm màu nền dự phòng
          ),

          const SizedBox(width: 20),

          //Details
          Expanded( // Sử dụng Expanded để tránh overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Author age
                Text(
                  "$authorAge yrs old",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 10),

                //Author name (F+L)
                Text(
                  authorName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2, // Cho phép tên xuống dòng
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                //Author rating
                Ratings(rating: authorRating),
              ],
            ),
          ),

          const SizedBox(width: 10),

          //Arrow
          const Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black26,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}