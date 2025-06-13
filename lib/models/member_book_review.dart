
import '../utils/helper.dart';

class MemberBookReview {
  final String text;
  final int rating;
  final DateTime date;
  final int mId;
  final int aId;
  final String aFirstName;
  final String aLastName;
  // Cải tiến: Ảnh của tác giả có thể không tồn tại (null).
  final String? aImageUrl;

  const MemberBookReview({
    required this.text,
    required this.rating,
    required this.date,
    required this.mId,
    required this.aId,
    required this.aFirstName,
    required this.aLastName,
    this.aImageUrl, // Không 'required' vì có thể null
  });

  factory MemberBookReview.fromJson(Map<String, dynamic> json) {
    return MemberBookReview(
      text: json['text'] as String,
      rating: json['rating'] as int,
      date: Helper.dateDeserializer(json['date']) ?? DateTime.now(),
      mId: json['mId'] as int,
      aId: json['aId'] as int,
      aFirstName: json['aFirstName'] as String,
      aLastName: json['aLastName'] as String,
      // Xử lý trường có thể null từ JSON
      aImageUrl: json['aImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // Sửa lỗi crash: Trả về một map literal trực tiếp
    return {
      'text': text,
      'rating': rating,
      'date': Helper.dateSerializer(date),
      'mId': mId,
      'aId': aId,
      'aFirstName': aFirstName,
      'aLastName': aLastName,
      'aImageUrl': aImageUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MemberBookReview &&
              runtimeType == other.runtimeType &&
              text == other.text &&
              date == other.date &&
              mId == other.mId &&
              aId == other.aId;

  @override
  int get hashCode => text.hashCode ^ date.hashCode ^ mId.hashCode ^ aId.hashCode;

  @override
  String toString() {
    return 'MemberBookReview{text: $text, rating: $rating, date: $date, mId: $mId, aId: $aId, aFirstName: $aFirstName, aLastName: $aLastName}';
  }
}