import 'package:cloud_firestore/cloud_firestore.dart';

class BookReview {
  final String id; // ID của document đánh giá
  final int rating;
  final String review;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final DateTime createdAt;

  BookReview({
    required this.id,
    required this.rating,
    required this.review,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.createdAt,
  });

  // PHƯƠNG THỨC MỚI: Dùng để đọc dữ liệu từ Firestore
  factory BookReview.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return BookReview(
      id: snapshot.id,
      rating: data['rating'] as int,
      review: data['review'] as String,
      userId: data['userId'] as String,
      // Các trường về user có thể được lưu trực tiếp trong review
      // hoặc bạn có thể cần một lệnh truy vấn khác để lấy thông tin này.
      // Giả định chúng được lưu cùng review cho đơn giản.
      userName: data['userName'] as String? ?? 'Người dùng ẩn danh',
      userImageUrl: data['userImageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // PHƯƠNG THỨC CŨ: Dùng cho backend Oracle
  factory BookReview.fromJson(Map<String, dynamic> json) {
    return BookReview(
      id: json['br_id'].toString(),
      rating: json['br_rating'] as int,
      review: json['br_review'] as String,
      userId: json['m_id'].toString(),
      userName: json['m_first_name'] + ' ' + json['m_last_name'],
      userImageUrl: json['m_image_url'],
      // Giả sử ngày tạo là ngày hiện tại vì không có trong JSON cũ
      createdAt: DateTime.now(),
    );
  }

  // CẬP NHẬT: Dùng để ghi dữ liệu lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'review': review,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'createdAt': createdAt,
      // Thường thì bookId cũng được lưu ở đây để dễ truy vấn
      // 'bookId': bookId,
    };
  }
}