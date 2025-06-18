import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warehouse/utils/helper.dart';

class Book {
  final String id; // ID của document trong Firestore
  final String name;
  final int rating;
  final String bio;
  final String imageUrl;
  final DateTime? publishedDate;
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
      'authorIds': authorIds,
      'genreIds': genreIds,
    };
  }
}