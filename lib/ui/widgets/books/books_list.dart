import 'package:flutter/material.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../utils/enums/page_type_enum.dart';
import '../../../models/book.dart';
import '../common/ratings.dart';

class BooksList extends StatelessWidget {
  final List<Book> books;

  // SỬA LỖI: Cập nhật cú pháp constructor.
  const BooksList({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: books.length,
      separatorBuilder: (ctx, i) => const Divider(
        thickness: 1,
        height: 36,
      ),
      itemBuilder: (ctx, i) => InkWell(
        onTap: () {
          Helper.navigateToPage(
            context: context,
            page: PageType.BOOK,
            arguments: books[i].id,
          );
        },
        child: BooksListItem(
          // SỬA LỖI: Xử lý giá trị String? từ datePresenter bằng cách cung cấp giá trị dự phòng.
          bookPublishedDate: Helper.datePresenter(books[i].publishedDate) ?? 'N/A',
          bookTitle: books[i].name,
          bookRating: books[i].rating,
          bookImageUrl: books[i].imageUrl,
        ),
      ),
    );
  }
}

class BooksListItem extends StatelessWidget {
  // SỬA LỖI: Cập nhật cú pháp constructor.
  const BooksListItem({
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
      padding: EdgeInsets.fromLTRB(Helper.hPadding, 0, Helper.hPadding, 0), // Giảm padding trên/dưới để khớp với separator
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          //Titles
          Expanded( // Bọc trong Expanded để tránh lỗi overflow
            child: SizedBox(
              height: 160, // Đặt chiều cao bằng ảnh để căn chỉnh tốt hơn
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung theo chiều dọc
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

                  const Spacer(), // Đẩy rating xuống dưới

                  //Book rating
                  Ratings(rating: bookRating),
                ],
              ),
            ),
          ),

          //Arrow
          const Padding(
            padding: EdgeInsets.only(left: 5, top: 60), // Căn chỉnh lại icon mũi tên
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