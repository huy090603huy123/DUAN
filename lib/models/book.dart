import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warehouse/utils/helper.dart'; // Giả sử bạn có tệp helper này

class Book {
  final String id; // ID của document trong Firestore
  final String name;
  final int rating;
  final String bio;
  final String imageUrl;
  final DateTime? publishedDate;
  final int quantity; // <-- THÊM MỚI: Số lượng sách
  // Thêm các trường để lưu trữ ID của các document liên quan
  final List<String> authorIds;
  final List<String> genreIds;

  Book({
    required this.id,
    required this.name,
    required this.rating,
    required this.bio,
    required this.imageUrl,
    this.publishedDate,
    this.quantity = 0, // <-- CẬP NHẬT: Thêm vào constructor với giá trị mặc định
    this.authorIds = const [],
    this.genreIds = const [],
  });

  String get bookInitials => Helper.getInitials(fullName: name);

  // PHƯƠNG THỨC MỚI: Dùng để đọc dữ liệu từ Firestore
  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Book(
      id: snapshot.id,
      name: data['name'] ?? '',
      rating: data['rating'] ?? 0,
      bio: data['bio'] ?? '',
      imageUrl: data['imageUrl'] ?? Helper.bookPlaceholder,
      publishedDate: data['publishedDate'] != null
          ? (data['publishedDate'] as Timestamp).toDate()
          : null,
      quantity: data['quantity'] ?? 0, // <-- CẬP NHẬT: Đọc số lượng từ Firestore
      // Đọc mảng các ID, chuyển đổi từ List<dynamic> thành List<String>
      authorIds: List<String>.from(data['authorIds'] ?? []),
      genreIds: List<String>.from(data['genreIds'] ?? []),
    );
  }

  // PHƯƠG THỨC CŨ: Dùng cho backend Oracle (có thể xóa đi)
  factory Book.fromJson(Map<String, dynamic> data) {
    return Book(
      id: data['bk_id'].toString(),
      name: data['bk_name'],
      rating: data['bk_rating'],
      bio: data['bk_bio'],
      imageUrl: data['bk_image_url'] ?? Helper.bookPlaceholder,
      publishedDate: data['bk_published_date'] == null
          ? null
          : DateTime.parse(
        data['bk_published_date'],
      ),
      quantity: data['bk_quantity'] ?? 0, // <-- CẬP NHẬT: Thêm cả vào đây nếu bạn vẫn dùng
    );
  }

  // CẬP NHẬT: Dùng để ghi dữ liệu lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rating': rating,
      'bio': bio,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate,
      'quantity': quantity, // <-- CẬP NHẬT: Thêm số lượng khi ghi dữ liệu
      'authorIds': authorIds,
      'genreIds': genreIds,
    };
  }
}