// lib/providers/book_details_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:warehouse/models/author.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/models/book_review.dart';
import 'package:warehouse/models/genre.dart';
import '../services/repositories/data_repository.dart';

import 'package:warehouse/utils/enums/status_enum.dart';

class BookDetailsProvider with ChangeNotifier {
  final DataRepository _dataRepository;
  final String bookId;

  // Trạng thái của Provider
  Status _status = Status.INITIAL;
  Status get status => _status;

  // Dữ liệu chi tiết sách
  Book? _book;
  List<Author> _authors = [];
  List<Genre> _genres = [];
  // Stream cho các đánh giá để chúng có thể được cập nhật real-time
  Stream<List<BookReview>>? reviewsStream;

  Book? get book => _book;
  List<Author> get authors => _authors;
  List<Genre> get genres => _genres;

  BookDetailsProvider({
    required DataRepository dataRepository,
    required this.bookId,
  }) : _dataRepository = dataRepository {
    // Bắt đầu tải tất cả dữ liệu khi Provider được tạo
    _fetchAllBookDetails();
  }

  Future<void> _fetchAllBookDetails() async {
    try {
      _status = Status.LOADING;
      notifyListeners();

      // 1. Lấy dữ liệu sách cơ bản
      // Sử dụng .first để lấy giá trị đầu tiên từ stream như một Future
      _book = await _dataRepository.bookDetailsStream(bookId).first;
      if (_book == null) {
        throw Exception("Không tìm thấy sách.");
      }

      // 2. Lấy stream các đánh giá
      reviewsStream = _dataRepository.bookReviews(bookId);

      // 3. Lấy danh sách tác giả và thể loại dựa trên IDs từ sách
      // Chạy song song để tăng tốc độ
      final futureAuthors = _dataRepository.getAuthorsByIds(_book!.authorIds);
      final futureGenres = _dataRepository.getGenresByIds(_book!.genreIds);

      // Đợi cả hai hoàn thành
      final results = await Future.wait([futureAuthors, futureGenres]);
      _authors = results[0] as List<Author>;
      _genres = results[1] as List<Genre>;

      _status = Status.DONE;
    } catch (e) {
      print("Lỗi khi tải chi tiết sách: $e");
      _status = Status.ERROR;
    } finally {
      notifyListeners();
    }
  }
}