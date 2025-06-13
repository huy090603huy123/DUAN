class Genre {
  /// The unique identifier for the genre.
  final int id;

  /// The name of the genre (e.g., "Science Fiction", "Fantasy").
  final String name;

  /// Creates a constant Genre object.
  /// Both [id] and [name] are required.
  const Genre({
    required this.id,
    required this.name,
  });

  /// Creates a Genre instance from a JSON map.
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['g_id'] as int,
      name: json['g_name'] as String,
    );
  }

  /// Converts this Genre instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'g_id': id,
      'g_name': name,
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