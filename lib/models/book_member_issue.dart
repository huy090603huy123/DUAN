import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warehouse/utils/enums/book_issue_status_enum.dart';

class MemberBookIssue {
  final String id;
  final String bookId;
  final String userId;
  final String bookName;
  final String bookImageUrl;
  final String authorName;
  final DateTime issueDate;
  final DateTime? dueDate;
  final DateTime? actualReturnDate; // <-- SỬA 1: Đổi tên trường cho rõ nghĩa
  final BookIssueStatus status;      // <-- SỬA 2: Đổi kiểu dữ liệu sang Enum

  MemberBookIssue({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.bookName,
    required this.bookImageUrl,
    required this.authorName,
    required this.issueDate,
    this.dueDate,
    this.actualReturnDate,
    required this.status,
  });

  factory MemberBookIssue.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;

    // Chuyển đổi String từ Firestore thành Enum bằng hàm đã tạo
    final statusString = data['status'] as String? ?? 'ISSUED';
    final statusEnum = BookIssueStatus.fromString(statusString);

    return MemberBookIssue(
      id: snapshot.id,
      bookId: data['bookId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      bookName: data['bookName'] as String? ?? 'Unknown Book',
      bookImageUrl: data['bookImageUrl'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Unknown Author',
      issueDate: (data['issueDate'] as Timestamp).toDate(),
      // Sửa tên trường đọc từ Firestore cho đúng
      actualReturnDate: data['actualReturnDate'] != null
          ? (data['actualReturnDate'] as Timestamp).toDate()
          : null,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      status: statusEnum, // Gán giá trị Enum đã chuyển đổi
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'userId': userId,
      'bookName': bookName,
      'bookImageUrl': bookImageUrl,
      'authorName': authorName,
      'issueDate': issueDate,
      'actualReturnDate': actualReturnDate, // Sửa tên trường khi ghi
      'dueDate': dueDate,
      'status': status.name, // Lưu tên của enum dưới dạng String
    };
  }
}