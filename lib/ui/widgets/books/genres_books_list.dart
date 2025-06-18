import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/publishes_provider.dart';
import '../../../utils/enums/page_type_enum.dart';
import '../../../utils/helper.dart';
import '../../../models/book.dart';
import '../common/ratings.dart';

class GenreBooksList extends StatelessWidget {
  // SỬA LỖI 1: ID của genre giờ là String
  final String genreId;
  final String searchTerm;

  const GenreBooksList({
    super.key,
    required this.genreId,
    this.searchTerm = "",
  });

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI 2: Gọi đúng phương thức mới là getBooksByGenreId
    return StreamBuilder<List<Book>>(
      stream: Provider.of<PublishesProvider>(context, listen: false)
          .getBooksByGenreId(genreId),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Đã có lỗi xảy ra."));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không tìm thấy sách nào cho thể loại này."));
        }

        List<Book> genreBooks = snapshot.data!;

        if (searchTerm.isNotEmpty) {
          genreBooks = genreBooks
              .where((book) =>
              book.name.toLowerCase().contains(searchTerm.toLowerCase()))
              .toList();
        }

        if (genreBooks.isEmpty) {
          return const Center(child: Text("Không tìm thấy sách phù hợp."));
        }

        return ListView.separated(
          itemCount: genreBooks.length,
          separatorBuilder: (ctx, i) => const Divider(
            thickness: 1,
            height: 36,
          ),
          itemBuilder: (ctx, i) {
            final book = genreBooks[i];
            return InkWell(
              onTap: () {
                Helper.navigateToPage(
                  context: context,
                  page: PageType.BOOK,
                  arguments: book.id,
                );
              },
              child: GenresBooksListItem(
                bookPublishedDate: Helper.datePresenter(book.publishedDate) ?? 'N/A',
                bookTitle: book.name,
                bookRating: book.rating,
                // SỬA LỖI 3: Cung cấp ảnh mặc định nếu imageUrl là null
                bookImageUrl: book.imageUrl ?? Helper.bookPlaceholder,
              ),
            );
          },
        );
      },
    );
  }
}

class GenresBooksListItem extends StatelessWidget {
  const GenresBooksListItem({
    super.key,
    required this.bookRating,
    required this.bookPublishedDate,
    required this.bookTitle,
    required this.bookImageUrl,
  });

  final int bookRating;
  final String bookPublishedDate;
  final String bookTitle;
  final String bookImageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: 115,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(bookImageUrl),
                fit: BoxFit.fill,
                // Xử lý lỗi tải ảnh
                onError: (exception, stackTrace) {
                  // Có thể log lỗi ở đây
                },
              ),
              color: Colors.grey.shade200, // Màu nền dự phòng
              borderRadius: BorderRadius.circular(20),
            ),
            // Widget con để hiển thị icon lỗi nếu ảnh không tải được
            child: (bookImageUrl.isEmpty || bookImageUrl == Helper.bookPlaceholder)
                ? const Icon(Icons.book, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bookPublishedDate,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bookTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Ratings(rating: bookRating),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5, top: 60),
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
