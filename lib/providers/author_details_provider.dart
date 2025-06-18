// lib/providers/author_details_provider.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/author.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/models/author_review.dart'; // Đảm bảo bạn đã tạo model này
import 'package:warehouse/services/repositories/data_repository.dart';
import 'package:warehouse/utils/enums/status_enum.dart';

class AuthorDetailsProvider with ChangeNotifier {
  final DataRepository _dataRepository;
  final String authorId;

  Status _status = Status.INITIAL;
  Status get status => _status;

  Author? _author;
  Author? get author => _author;

  // Streams cho sách và reviews để cập nhật real-time
  Stream<List<Book>>? booksStream;
  Stream<List<AuthorReview>>? reviewsStream;

  AuthorDetailsProvider({
    required DataRepository dataRepository,
    required this.authorId,
  }) : _dataRepository = dataRepository {
    _fetchAllAuthorDetails();
  }

  Future<void> _fetchAllAuthorDetails() async {
    try {
      _status = Status.LOADING;
      notifyListeners();

      // 1. Lấy dữ liệu tác giả
      _author = await _dataRepository.authorDetailsStream(authorId).first;
      if (_author == null) {
        throw Exception("Không tìm thấy tác giả.");
      }

      // 2. Lấy stream sách của tác giả
      booksStream = _dataRepository.getBooksByAuthorId(authorId);

      // 3. Lấy stream các bài đánh giá về tác giả
      // Giả sử bạn có model AuthorReview và phương thức authorReviews trong DataRepository
      // reviewsStream = _dataRepository.authorReviews(authorId);

      _status = Status.DONE;
    } catch (e) {
      print("Lỗi khi tải chi tiết tác giả: $e");
      _status = Status.ERROR;
    } finally {
      notifyListeners();
    }
  }
}