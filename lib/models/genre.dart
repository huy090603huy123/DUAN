import 'package:cloud_firestore/cloud_firestore.dart';

class Genre {
  /// The unique identifier for the genre from Firestore.
  final String id;

  /// The name of the genre (e.g., "Science Fiction", "Fantasy").
  final String name;

  /// Creates a Genre object.
  Genre({
    required this.id,
    required this.name,
  });

  // PHƯƠNG THỨC MỚI: Dùng để đọc dữ liệu từ Firestore
  factory Genre.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Genre(
      id: snapshot.id,
      name: data['name'] as String,
    );
  }

  /// Creates a Genre instance from a JSON map (for the old Oracle backend).
  /// You can keep this for reference or remove it.
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['g_id'].toString(), // Convert to String to be consistent
      name: json['g_name'] as String,
    );
  }

  /// CẬP NHẬT: Dùng để ghi dữ liệu lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Genre && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Genre{id: $id, name: $name}';
  }
}