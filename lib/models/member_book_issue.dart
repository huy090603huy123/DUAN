import 'package:cloud_firestore/cloud_firestore.dart';

class MemberBookIssue {
  final String id;
  final String bookId;
  final String userId;
  final String bookName;
  final String bookImageUrl;
  final String authorName; // ĐÃ THÊM
  final DateTime issueDate;
  final DateTime? returnDate;
  final DateTime? dueDate;    // ĐÃ THÊM

  /// Trạng thái được lưu dưới dạng String: 'ISSUED', 'RETURNED', 'OVERDUE'
  final String status;

  MemberBookIssue({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.bookName,
    required this.bookImageUrl,
    required this.authorName, // ĐÃ THÊM
    required this.issueDate,
    this.returnDate,
    this.dueDate, // ĐÃ THÊM
    required this.status,
  });

  factory MemberBookIssue.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return MemberBookIssue(
      id: snapshot.id,
      bookId: data['bookId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      bookName: data['bookName'] as String? ?? 'Unknown Book',
      bookImageUrl: data['bookImageUrl'] as String? ?? '',
      // Giả định các trường này được thêm vào khi tạo lượt mượn
      authorName: data['authorName'] as String? ?? 'Unknown Author',
      issueDate: (data['issueDate'] as Timestamp).toDate(),
      returnDate: data['returnDate'] != null
          ? (data['returnDate'] as Timestamp).toDate()
          : null,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      status: data['status'] as String? ?? 'ISSUED',
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
      'returnDate': returnDate,
      'dueDate': dueDate,
      'status': status,
    };
  }
}
