import 'package:flutter/foundation.dart';
import '../utils/helper.dart';

class MemberAuthorReview {
  final String text;
  final int rating;
  final DateTime date;
  final int mId;
  final int bkId;
  final String bkName;
  // Sửa lỗi logic: Rating của sách nên là một con số (int), không phải chuỗi (String).
  final int bkRating;
  final String bkImageUrl;

  const MemberAuthorReview({
    required this.text,
    required this.rating,
    required this.date,
    required this.mId,
    required this.bkId,
    required this.bkName,
    required this.bkRating,
    required this.bkImageUrl,
  });

  factory MemberAuthorReview.fromJson(Map<String, dynamic> json) {
    return MemberAuthorReview(
      text: json['text'] as String,
      rating: json['rating'] as int,
      date: Helper.dateDeserializer(json['date']) ?? DateTime.now(),
      mId: json['mId'] as int,
      bkId: json['bkId'] as int,
      bkName: json['bkName'] as String,
      // Sửa JSON: Chuyển đổi bkRating thành int
      bkRating: json['bkRating'] as int,
      bkImageUrl: json['bkImageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    // Sửa lỗi crash: Trả về một map literal trực tiếp
    return {
      'text': text,
      'rating': rating,
      'date': Helper.dateSerializer(date),
      'mId': mId,
      'bkId': bkId,
      'bkName': bkName,
      'bkRating': bkRating,
      'bkImageUrl': bkImageUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MemberAuthorReview &&
              runtimeType == other.runtimeType &&
              text == other.text &&
              date == other.date &&
              mId == other.mId &&
              bkId == other.bkId;

  @override
  int get hashCode => text.hashCode ^ date.hashCode ^ mId.hashCode ^ bkId.hashCode;

  @override
  String toString() {
    return 'MemberAuthorReview{text: $text, rating: $rating, date: $date, mId: $mId, bkId: $bkId, bkName: $bkName, bkRating: $bkRating}';
  }
}