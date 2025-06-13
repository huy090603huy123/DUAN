

import '../utils/helper.dart';
import '../utils/enums/book_issue_status_enum.dart';
import 'book_copy.dart';

class MemberBookIssue {
  final int issueId;
  final int mId;
  final BookCopy bookCopy;
  final DateTime issueDate;
  final DateTime dueDate;
  // Sửa lỗi logic: Ngày trả sách có thể là null nếu sách chưa được trả.
  final DateTime? returnedDate;
  final String bookName;
  final String authorName;
  final String bookImageUrl;

  const MemberBookIssue({
    required this.issueId,
    required this.mId,
    required this.bookCopy,
    required this.issueDate,
    required this.dueDate,
    this.returnedDate, // Không 'required' vì có thể null
    required this.bookName,
    required this.authorName,
    required this.bookImageUrl,
  });

  factory MemberBookIssue.fromJson(Map<String, dynamic> json) {
    return MemberBookIssue(
      issueId: json['issue_id'] as int,
      mId: json['m_id'] as int,
      bookCopy: BookCopy(copyId: json['copy_id'], bkId: json['bk_id']),
      issueDate: Helper.dateDeserializer(json['date']) ?? DateTime.now(),
      dueDate: Helper.dateDeserializer(json['date']) ?? DateTime.now(),
      bookName: json['bk_name'] as String,
      authorName: json['a_name'] as String,
      bookImageUrl: json['bk_image_url'] as String,
      // Logic xử lý null đã đúng, chỉ cần truyền vào constructor mới
      returnedDate:
      json['returned_date'] != null ? Helper.dateDeserializer(json['returned_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue_id': issueId,
      'm_id': mId,
      'bk_id': bookCopy.bkId,
      'copy_id': bookCopy.copyId,
      'bk_name': bookName,
      'a_name': authorName,
      'bk_image_url': bookImageUrl,
      'issue_date': issueDate,
      'due_date': dueDate,
      'returned_date': returnedDate,
    };
  }

  BookIssueStatus get status {
    // Logic này giờ hoàn toàn an toàn với kiểu dữ liệu nullable
    if (returnedDate != null) return BookIssueStatus.RETURNED;
    if (dueDate.isBefore(DateTime.now())) return BookIssueStatus.OVERDUE;
    return BookIssueStatus.DUE;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MemberBookIssue && runtimeType == other.runtimeType && issueId == other.issueId;

  @override
  int get hashCode => issueId.hashCode;

  @override
  String toString() {
    return 'MemberBookIssue{issueId: $issueId, mId: $mId, bookCopy: $bookCopy, issueDate: $issueDate, dueDate: $dueDate, returnedDate: $returnedDate, bookName: $bookName, authorName: $authorName}';
  }
}