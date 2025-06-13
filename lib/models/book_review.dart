import '../utils/helper.dart';

class BookReview {
  final String text;
  final int rating;
  final DateTime date;
  final int bookId;
  final int mId;
  final String mFirstName;
  final String mLastName;
  final String mImageUrl;

  const BookReview({
    required this.text,
    required this.rating,
    required this.date,
    required this.bookId,
    required this.mId,
    required this.mFirstName,
    required this.mLastName,
    required this.mImageUrl,
  });

  factory BookReview.fromJson(Map<String, dynamic> json) {
    return BookReview(
      text: json['text'] as String,
      rating: json['rating'] as int,
      date: Helper.dateDeserializer(json['date']) ?? DateTime.now(),
      bookId: json['bookId'] as int,
      mId: json['mId'] as int,
      mFirstName: json['mFirstName'] as String,
      mLastName: json['mLastName'] as String,
      mImageUrl: json['mImageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    // Sửa lỗi nghiêm trọng: Trả về một map được khởi tạo trực tiếp
    return {
      'text': text,
      'rating': rating,
      'date': Helper.dateSerializer(date),
      'bookId': bookId,
      'mId': mId,
      'mFirstName': mFirstName,
      'mLastName': mLastName,
      'mImageUrl': mImageUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BookReview &&
              runtimeType == other.runtimeType &&
              text == other.text &&
              date == other.date &&
              bookId == other.bookId &&
              mId == other.mId;

  @override
  int get hashCode =>
      text.hashCode ^ date.hashCode ^ bookId.hashCode ^ mId.hashCode;

  @override
  String toString() {
    return 'BookReview{text: $text, rating: $rating, date: $date, bookId: $bookId, mId: $mId, mFirstName: $mFirstName, mLastName: $mLastName}';
  }
}