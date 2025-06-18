import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warehouse/utils/helper.dart';

class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String? bio;
  final int age;
  final String email;
  final String? imageUrl;
  final DateTime? startDate;
  final List<String> preferredGenreIds;
  // THÊM MỚI: Trường để lưu vai trò của người dùng
  final String role;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.bio,
    required this.age,
    required this.email,
    this.imageUrl,
    this.startDate,
    this.preferredGenreIds = const [],
    // THÊM MỚI: Thêm vào constructor, mặc định là 'user'
    this.role = 'user',
  });

  String get memberName => '$firstName $lastName';
  String get memberInitials => Helper.getInitials(fullName: memberName);

  factory Member.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Member(
      id: snapshot.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      bio: data['bio'],
      age: data['age'] ?? 0,
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'],
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      preferredGenreIds: List<String>.from(data['preferredGenreIds'] ?? []),
      // THÊM MỚI: Đọc vai trò từ Firestore, nếu không có thì mặc định là 'user'
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'age': age,
      'email': email,
      'imageUrl': imageUrl,
      'startDate': startDate,
      'preferredGenreIds': preferredGenreIds,
      // THÊM MỚI: Thêm vai trò vào hàm toJson
      'role': role,
    };
  }
}
