import '../utils/helper.dart';

class Member {
  final int id;
  final String firstName;
  final String lastName;
  final String bio;
  final DateTime startDate;
  final int age;
  // Thay đổi: imageUrl có thể null, dựa trên logic của getter 'hasImage'
  final String? imageUrl;
  final String email;
  final String password;

  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.startDate,
    required this.age,
    this.imageUrl, // Không 'required' vì có thể null
    required this.email,
    required this.password,
  });

  /// Một getter tiện lợi để kiểm tra xem thành viên có ảnh đại diện không.
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Tạo một bản sao của Member nhưng với các trường được chỉ định đã thay đổi.
  Member copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? bio,
    DateTime? startDate,
    int? age,
    String? imageUrl,
    String? email,
    String? password,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      startDate: startDate ?? this.startDate,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  /// Tạo một đối tượng Member từ JSON.
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['m_id'] as int,
      firstName: json['m_first_name'] as String,
      lastName: json['m_last_name'] as String,
      bio: json['m_bio'] as String,
      startDate: Helper.dateDeserializer(json['date']) ?? DateTime.now(),
      age: json['m_age'] as int,
      email: json['m_email'] as String,
      password: json['m_password'] as String,
      // Xử lý trường có thể null từ JSON
      imageUrl: json['m_image_url'] as String?,
    );
  }

  /// Chuyển đối tượng Member thành một map JSON.
  Map<String, dynamic> toJson() {
    return {
      'm_id': id,
      'm_first_name': firstName,
      'm_last_name': lastName,
      'm_bio': bio,
      'm_start_date': Helper.dateSerializer(startDate),
      'm_age': age,
      'm_email': email,
      'm_password': password,
      'm_image_url': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Member && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Member{id: $id, email: $email, firstName: $firstName, lastName: $lastName}';
  }
}