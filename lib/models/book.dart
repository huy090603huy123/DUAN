import 'package:flutter/foundation.dart';

import '../utils/helper.dart';

class Book {
  final int id;
  final String name;
  final int rating;
  final String bio;
  final String imageUrl;
  // Thay đổi: publishedDate có thể là null (DateTime?)
  final DateTime? publishedDate;

  const Book({
    required this.id,
    required this.name,
    required this.rating,
    required this.bio,
    required this.imageUrl,
    this.publishedDate, // Không 'required' nữa vì có thể null
  });

  factory Book.initialData() {
    return Book(
      id: 0,
      name: '',
      imageUrl: Helper.bookPlaceholder,
      publishedDate: null, // Bây giờ hợp lệ vì publishedDate là nullable
      rating: 0,
      bio: '',
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['bk_id'] as int,
      name: json['bk_name'] as String,
      rating: json['bk_rating'] as int,
      bio: json['bk_bio'] as String,
      imageUrl: json['bk_image_url'] as String,
      // Xử lý giá trị có thể null từ JSON
      publishedDate: json["bk_published_date"] == null
          ? null
          : Helper.dateDeserializer(json["bk_published_date"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bk_id': id,
      'bk_name': name,
      'bk_rating': rating,
      'bk_bio': bio,
      'bk_image_url': imageUrl,
      // Xử lý giá trị có thể null khi chuyển thành JSON
      'bk_published_date': publishedDate == null
          ? null
          : Helper.dateSerializer(publishedDate!),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Book && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Book{id: $id, name: $name, rating: $rating, publishedDate: $publishedDate}';
  }
}