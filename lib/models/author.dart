class Author {
  final int id;
  final int age;
  final int rating;
  final String firstName;
  final String lastName;
  final String country;
  final String imageUrl;

  // Sử dụng constructor với cú pháp 'this' để khởi tạo trực tiếp
  // Thêm 'required' để đảm bảo các tham số này phải được cung cấp
  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.country,
    required this.rating,
    required this.imageUrl,
  });

  // Không cần getter tường minh nữa vì các thuộc tính đã public
  // Dart sẽ tự tạo getter cho các thuộc tính public final

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['a_id'] as int,
      firstName: json['a_first_name'] as String,
      lastName: json['a_last_name'] as String,
      age: json['a_age'] as int,
      country: json['a_country'] as String,
      rating: json['a_rating'] as int,
      imageUrl: json['a_image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['a_id'] = id;
    data['a_first_name'] = firstName;
    data['a_last_name'] = lastName;
    data['a_age'] = age;
    data['a_country'] = country;
    data['a_rating'] = rating;
    data['a_image_url'] = imageUrl;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Author && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Author{id: $id, age: $age, firstName: $firstName, lastName: $lastName, country: $country}';
  }
}