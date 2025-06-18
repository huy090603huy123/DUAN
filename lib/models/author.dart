import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warehouse/utils/helper.dart';

class Author {
  final String id;
  final String firstName;
  final String lastName;
  final String? country;
  final int rating;
  final String? imageUrl;
  final int age; // THÊM MỚI

  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.country,
    required this.rating,
    this.imageUrl,
    required this.age, // THÊM MỚI
  });

  String get authorName => '$firstName $lastName';
  String get authorInitials => Helper.getInitials(fullName: authorName);

  factory Author.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Author(
      id: snapshot.id,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      country: data['country'] as String?,
      rating: data['rating'] as int,
      imageUrl: data['imageUrl'] as String?,
      age: data['age'] as int? ?? 0, // THÊM MỚI (xử lý trường hợp null)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'rating': rating,
      'imageUrl': imageUrl,
      'age': age, // THÊM MỚI
    };
  }
}
