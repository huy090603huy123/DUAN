import 'package:flutter/material.dart';

import 'publishes_provider.dart';
import 'genres_provider.dart';
import 'reviews_provider.dart';

import '../models/book.dart';
import '../models/genre.dart';
import '../models/author.dart';
import '../models/author_review.dart';
import '../models/author_details.dart';

class AuthorDetailsProvider with ChangeNotifier {
  final PublishesProvider _publishesProvider;
  final GenresProvider _genresProvider;
  final ReviewsProvider _reviewsProvider;

  // SỬA LỖI: Thay @required bằng required và dùng cú pháp khởi tạo đúng
  AuthorDetailsProvider({
    required PublishesProvider publishesProvider,
    required GenresProvider genresProvider,
    required ReviewsProvider reviewsProvider,
  })  : _publishesProvider = publishesProvider,
        _genresProvider = genresProvider,
        _reviewsProvider = reviewsProvider;

  /// Fetch authorDetails for authorId
  // SỬA LỖI: Thay đổi kiểu trả về để cho phép null
  Future<AuthorDetails?> getAuthorDetails(int aId) async {
    late List<Book> authorBooks;
    late List<Genre> authorGenres;
    late List<AuthorReview> authorReviews;

    // SỬA LỖI: Khai báo biến author có thể null (Author?)
    final Author? author = _publishesProvider.getAuthor(aId);

    // SỬA LỖI: Nếu không tìm thấy tác giả, trả về null ngay lập tức
    if (author == null) {
      return null;
    }

    await Future.wait<void>([
      (() async => authorBooks = await _publishesProvider.getAuthorBooks(aId))(),
      (() async => authorGenres = await _genresProvider.getAuthorGenres(aId))(),
      (() async => authorReviews = await _reviewsProvider.getAuthorReviews(aId))(),
    ]);

    return AuthorDetails(
      genres: authorGenres,
      books: authorBooks,
      reviews: authorReviews,
      author: author, // 'author' ở đây đã được xác nhận là không null, nên nó hợp lệ
    );
  }
}