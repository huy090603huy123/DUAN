import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, approved, rejected }

class BorrowRequest {
  final String? id;
  final String bookId;
  final String userId;
  final String bookTitle;
  final String userName;
  final String? bookImage;
  final DateTime requestDate;
  RequestStatus status;

  BorrowRequest({
    this.id,
    required this.bookId,
    required this.userId,
    required this.bookTitle,
    required this.userName,
    this.bookImage,
    required this.requestDate,
    this.status = RequestStatus.pending,
  });

  factory BorrowRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BorrowRequest(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      userId: data['userId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      userName: data['userName'] ?? '',
      bookImage: data['bookImage'],
      requestDate: (data['requestDate'] as Timestamp).toDate(),
      status: RequestStatus.values.firstWhere(
            (e) => e.toString() == 'RequestStatus.${data['status']}',
        orElse: () => RequestStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'bookTitle': bookTitle,
      'userName': userName,
      'bookImage': bookImage,
      'requestDate': Timestamp.fromDate(requestDate),
      'status': status.toString().split('.').last,
    };
  }
}