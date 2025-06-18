// lib/providers/reviews_provider.dart
import 'package:flutter/material.dart';
import 'package:warehouse/services/repositories/data_repository.dart';

class ReviewsProvider with ChangeNotifier {
  final DataRepository _dataRepository;

  ReviewsProvider({required DataRepository dataRepository})
      : _dataRepository = dataRepository;

  // Hàm để đăng một bài đánh giá sách
  Future<void> postBookReview({
    required String bookId,
    required String userId,
    required int rating,
    required String review,
  }) async {
    // Logic này có thể phức tạp và nên được xử lý bằng một giao dịch (transaction)
    // trong DataRepository để đảm bảo tính nhất quán (cập nhật rating trung bình của sách).
    // await _dataRepository.postBookReview(...);
    print('Đăng review sách: $bookId, rating: $rating');
  }

  // Hàm để đăng một bài đánh giá tác giả
  Future<void> postAuthorReview({
    required String authorId,
    required String userId,
    required int rating,
    required String review,
  }) async {
    // Tương tự, nên dùng transaction trong DataRepository
    // await _dataRepository.postAuthorReview(...);
    print('Đăng review tác giả: $authorId, rating: $rating');
  }
}