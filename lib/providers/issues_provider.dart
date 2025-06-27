import 'package:flutter/material.dart';
import 'package:warehouse/services/repositories/data_repository.dart';
import 'package:warehouse/models/member_book_issue.dart';
import 'package:warehouse/models/book.dart';

class IssuesProvider with ChangeNotifier {
  final DataRepository _dataRepository;
  final String userId; // Provider này giờ cần userId để hoạt động

  IssuesProvider({
    required DataRepository dataRepository,
    required this.userId,
  }) : _dataRepository = dataRepository;

  // Cung cấp một stream các lượt mượn sách của người dùng
  Stream<List<MemberBookIssue>> get memberBookIssuesStream {
    // Luôn đảm bảo userId hợp lệ trước khi lắng nghe stream
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    return _dataRepository.memberBookIssues(userId);
  }

  /// Mượn một cuốn sách và cập nhật số lượng.
  /// Trả về `true` nếu thành công, `false` nếu thất bại.
  Future<bool> issueBook({
    required Book bookDetails,
    required String userId,
  }) async {
    // --- THAY ĐỔI 1: Logic mượn sách ---

    // Kiểm tra nhanh ở phía client để cải thiện trải nghiệm người dùng.
    // Việc kiểm tra cuối cùng và đáng tin cậy nhất vẫn nằm trong transaction ở repository.
    if (bookDetails.quantity <= 0) {
      print("Lỗi: Sách đã hết hàng.");
      // Có thể ném ra một Exception cụ thể để UI có thể bắt và hiển thị thông báo đẹp hơn.
      throw Exception('Sách đã hết, vui lòng quay lại sau.');
    }

    try {
      final issueData = {
        'userId': userId,
        'bookId': bookDetails.id,
        'bookName': bookDetails.name,
        'bookImageUrl': bookDetails.imageUrl,
        'authorName': 'Tên tác giả', // Tạm thời, cần lấy từ bookDetails.authorIds
        'issueDate': DateTime.now(),
        'dueDate': DateTime.now().add(const Duration(days: 30)),
        'returnDate': null,
        'status': 'DUE', // Trạng thái ban đầu là "Tới hạn"
      };

      // Gọi phương thức mới trong repository để thực hiện transaction
      await _dataRepository.issueBookAndUpdateQuantity(
        issueData: issueData,
        bookId: bookDetails.id,
      );

      notifyListeners(); // Thông báo cho các widget đang lắng nghe để cập nhật UI
      return true;
    } catch (e) {
      print("Lỗi khi thực hiện giao dịch mượn sách: $e");
      // Ném lại lỗi để UI có thể xử lý
      throw Exception('Đã xảy ra lỗi khi mượn sách. Vui lòng thử lại. $e');
    }
  }


  /// Trả một cuốn sách và cập nhật số lượng.
  /// Trả về `true` nếu thành công, `false` nếu thất bại.
  Future<bool> returnBook({
    required String issueId,
    required String bookId,
    required int rating,
    required String review,
  }) async {
    // --- THAY ĐỔI 2: Logic trả sách ---
    if (userId.isEmpty) {
      print("Lỗi: Không có ID người dùng để trả sách.");
      return false;
    }

    try {
      // Gọi phương thức mới trong repository để thực hiện transaction
      await _dataRepository.returnBookAndUpdateQuantity(
        issueId: issueId,
        bookId: bookId,
        userId: userId,
        rating: rating,
        review: review,
      );

      notifyListeners(); // Thông báo cho các widget đang lắng nghe để cập nhật UI
      return true;
    } catch (e) {
      print("Lỗi khi thực hiện giao dịch trả sách: $e");
      // Ném lại lỗi để UI có thể xử lý
      throw Exception('Đã xảy ra lỗi khi trả sách. Vui lòng thử lại.');
    }
  }
}