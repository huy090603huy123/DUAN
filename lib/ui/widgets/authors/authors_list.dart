import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/author.dart'; // Import model Author
import 'package:warehouse/utils/enums/page_type_enum.dart';

import '../../../providers/publishes_provider.dart';
import '../../../utils/helper.dart';
import '../common/ratings.dart';

class AuthorsList extends StatelessWidget {
  final String searchTerm;

  const AuthorsList({super.key, required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    final publishesProvider = Provider.of<PublishesProvider>(context, listen: false);

    // SỬA LỖI 1: Sử dụng StreamBuilder để lắng nghe luồng dữ liệu tác giả
    return StreamBuilder<List<Author>>(
      stream: publishesProvider.authorsStream,
      builder: (context, snapshot) {
        // Xử lý các trạng thái của stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Không thể tải danh sách tác giả.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không tìm thấy tác giả nào.'));
        }

        // Lấy dữ liệu từ snapshot
        final allAuthors = snapshot.data!;

        // Lọc danh sách tác giả dựa trên từ khóa tìm kiếm
        final filteredAuthors = allAuthors.where((author) {
          final searchTermLower = searchTerm.toLowerCase();
          final firstNameLower = author.firstName.toLowerCase();
          final lastNameLower = author.lastName.toLowerCase();
          return firstNameLower.contains(searchTermLower) ||
              lastNameLower.contains(searchTermLower);
        }).toList();

        if (filteredAuthors.isEmpty) {
          return const Center(child: Text('Không tìm thấy tác giả phù hợp.'));
        }

        return ListView.separated(
          itemCount: filteredAuthors.length,
          separatorBuilder: (ctx, i) => const Divider(
            thickness: 1,
            height: 36,
          ),
          itemBuilder: (ctx, i) {
            final author = filteredAuthors[i];
            return InkWell(
              onTap: () {
                Helper.navigateToPage(
                  context: context,
                  page: PageType.AUTHOR,
                  arguments: author.id,
                );
              },
              child: AuthorsListItem(
                authorAge: author.age,
                authorName: author.authorName, // Sử dụng getter cho tiện
                authorRating: author.rating,
                // SỬA LỖI 2: Cung cấp ảnh mặc định nếu imageUrl là null
                authorImageUrl: author.imageUrl ?? Helper.bookPlaceholder,
              ),
            );
          },
        );
      },
    );
  }
}

class AuthorsListItem extends StatelessWidget {
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
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(authorImageUrl),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$authorAge tuổi",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  authorName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Ratings(rating: authorRating),
              ],
            ),
          ),
          const SizedBox(width: 10),
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
