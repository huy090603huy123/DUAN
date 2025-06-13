import 'package:flutter/material.dart';

import 'publishes_provider.dart';
import 'genres_provider.dart';
import 'reviews_provider.dart';

import '../models/book.dart';
import '../models/genre.dart';
import '../models/author.dart';
import '../models/book_review.dart';
import '../models/book_details.dart';

class BookDetailsProvider with ChangeNotifier {
  final PublishesProvider _publishesProvider;
  final GenresProvider _genresProvider;
  final ReviewsProvider _reviewsProvider;

  // SỬA LỖI: Thay @required bằng required và dùng cú pháp khởi tạo đúng
  BookDetailsProvider({
    required PublishesProvider publishesProvider,
    required GenresProvider genresProvider,
    required ReviewsProvider reviewsProvider,
  })  : _publishesProvider = publishesProvider,
        _genresProvider = genresProvider,
        _reviewsProvider = reviewsProvider;

  /// Fetch bookDetails for bookId
  // SỬA LỖI: Thay đổi kiểu trả về để cho phép null
  Future<BookDetails?> getBookDetails(int bkId) async {
    late List<Author> bookAuthors;
    late List<Genre> bookGenres;
    late List<BookReview> bookReviews;

    /// get and store the book for bkId from _publishesProvider
    // SỬA LỖI: Khai báo biến book có thể null (Book?)
    final Book? book = _publishesProvider.getBook(bkId);

    // SỬA LỖI: Nếu không tìm thấy sách, trả về null ngay lập tức
    if (book == null) {
      return null;
    }

    await Future.wait<void>([
      (() async => bookAuthors = await _publishesProvider.getBookAuthors(bkId))(),
      (() async => bookGenres = await _genresProvider.getBookGenres(bkId))(),
      (() async => bookReviews = await _reviewsProvider.getBookReviews(bkId))(),
    ]);

    return BookDetails(
      genres: bookGenres,
      authors: bookAuthors,
      reviews: bookReviews,
      book: book, // 'book' ở đây đã được xác nhận là không null, nên nó hợp lệ
    );
  }
}