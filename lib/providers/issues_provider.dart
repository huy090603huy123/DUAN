// lib/providers/issues_provider.dart
import 'package:flutter/material.dart';
import 'package:warehouse/services/repositories/data_repository.dart';
import 'package:warehouse/models/member_book_issue.dart';

import '../models/book.dart';

class IssuesProvider with ChangeNotifier {
  final DataRepository _dataRepository;
  final String userId; // Provider này giờ cần userId để hoạt động

  IssuesProvider({
    required DataRepository dataRepository,
    required this.userId,
  }) : _dataRepository = dataRepository;

  // Cung cấp một stream các lượt mượn sách của người dùng
  Stream<List<MemberBookIssue>> get memberBookIssuesStream {
    if (userId == null) {
      // Trả về một stream rỗng nếu không có userId
      return Stream.value([]);
    }
    return _dataRepository.memberBookIssues(userId!);
  }

  Future<bool> issueBook({
    required String bookId,
    required String userId,
    required Book bookDetails, // Cần thông tin sách để lưu lại
  }) async {

    // Logic kiểm tra xem sách còn bản sao để mượn hay không (có thể thêm sau)
    //...

    try {
      final issueData = {
        'userId': userId,
        'bookId': bookId,
        'bookName': bookDetails.name,
        'bookImageUrl': bookDetails.imageUrl,
        'authorName': 'Tên tác giả', // Tạm thời, cần lấy từ bookDetails.authors
        'issueDate': DateTime.now(),
        // Tính ngày hết hạn, ví dụ 1 tháng
        'dueDate': DateTime.now().add(const Duration(days: 30)),
        'returnDate': null,
        'status': 'DUE', // Trạng thái ban đầu là "Tới hạn"
      };
      // Giả sử bạn có phương thức này trong DataRepository để thêm document
      await _dataRepository.addIssue(issueData);
      return true;
    } catch (e) {
      print("Lỗi khi mượn sách: $e");
      return false;
    }
  }


  // Hàm để trả sách

  Future<bool> returnBook({
    required String issueId,
    required String bookId,
    required int rating,
    required String review,
  }) async {
    if (userId == null || userId!.isEmpty) {
      print("Lỗi: Không có ID người dùng để trả sách.");
      return false;
    }
    try {
      await _dataRepository.returnBook(
        issueId: issueId,
        bookId: bookId,
        userId: userId!,
        rating: rating,
        review: review,
      );
      return true;
    } catch (e) {
      print("Lỗi khi trả sách: $e");
      return false;
    }
  }



}