import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/publishes_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/enums/page_type_enum.dart';
import '../../../utils/helper.dart';
import '../../../models/book.dart';
import '../common/ratings.dart';

class GenreBooksList extends StatelessWidget {
  final int gId;
  final String searchTerm;

  // SỬA LỖI: Cập nhật cú pháp constructor và cung cấp giá trị mặc định cho searchTerm
  const GenreBooksList({
    super.key,
    required this.gId,
    this.searchTerm = "",
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: Provider.of<PublishesProvider>(context, listen: false).getGenreBooks(gId),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("An error occurred."));
        }
        // SỬA LỖI: Kiểm tra cả hasData và data không phải là null
        if (snapshot.hasData && snapshot.data != null) {
          // SỬA LỖI: Gán snapshot.data! một cách an toàn
          List<Book> genreBooks = snapshot.data!;
          // Lọc danh sách nếu có searchTerm
          if (searchTerm.isNotEmpty) {
            genreBooks = genreBooks
                .where((book) => book.name.toLowerCase().contains(searchTerm.toLowerCase()))
                .toList();
          }

          if (genreBooks.isEmpty) {
            return const Center(child: Text("No books found."));
          }

          return ListView.separated(
            itemCount: genreBooks.length,
            separatorBuilder: (ctx, i) => const Divider(
              thickness: 1,
              height: 36,
            ),
            itemBuilder: (ctx, i) => InkWell(
              onTap: () {
                Helper.navigateToPage(
                  context: context,
                  page: PageType.BOOK,
                  arguments: genreBooks[i].id,
                );
              },
              child: GenresBooksListItem(
                // SỬA LỖI: Xử lý giá trị String? từ datePresenter
                bookPublishedDate: Helper.datePresenter(genreBooks[i].publishedDate) ?? 'N/A',
                bookTitle: genreBooks[i].name,
                bookRating: genreBooks[i].rating,
                bookImageUrl: genreBooks[i].imageUrl,
              ),
            ),
          );
        }
        // Fallback nếu không có dữ liệu
        return const Center(
          child: Text("No books found for this genre."),
        );
      },
    );
  }
}

class GenresBooksListItem extends StatelessWidget {
  // SỬA LỖI: Cập nhật cú pháp constructor
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
          //Book Image
          Container(
            height: 160,
            width: 115,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(bookImageUrl),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(width: 20),

          //Titles
          Expanded( // Thêm Expanded để tránh overflow
            child: SizedBox(
              height: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Published Date
                  Text(
                    bookPublishedDate,
                    style: TextStyle(
                      // SỬA LỖI: Sử dụng cách truy cập màu an toàn
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 8),

                  //Book Title
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

                  //Book rating
                  Ratings(rating: bookRating),
                ],
              ),
            ),
          ),

          //Arrow
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