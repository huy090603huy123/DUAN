import 'package:flutter/material.dart';

enum BookIssueStatus {
  ISSUED,
  RETURNED,
  OVERDUE,
  DUE; // Dùng dấu chấm phẩy khi có nội dung bên trong enum

  /// Cung cấp tên hiển thị Tiếng Việt cho từng trạng thái
  String get displayName {
    switch (this) {
      case BookIssueStatus.ISSUED:
        return 'Đang mượn';
      case BookIssueStatus.RETURNED:
        return 'Đã trả';
      case BookIssueStatus.OVERDUE:
        return 'Quá hạn';
      case BookIssueStatus.DUE:
        return 'Sắp đến hạn';
    }
  }

  /// Cung cấp màu sắc tương ứng cho từng trạng thái
  Color get displayColor {
    switch (this) {
      case BookIssueStatus.ISSUED:
        return Colors.blue.shade700;
      case BookIssueStatus.RETURNED:
        return Colors.green.shade700;
      case BookIssueStatus.OVERDUE:
        return Colors.red.shade700;
      case BookIssueStatus.DUE:
        return Colors.orange.shade700;
    }
  }

  /// Hàm tiện ích để chuyển đổi String từ Firestore thành Enum
  static BookIssueStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ISSUED':
        return BookIssueStatus.ISSUED;
      case 'RETURNED':
        return BookIssueStatus.RETURNED;
      case 'OVERDUE':
        return BookIssueStatus.OVERDUE;
      case 'DUE':
        return BookIssueStatus.DUE;
      default:
      // Trả về một giá trị mặc định an toàn
        return BookIssueStatus.ISSUED;
    }
  }
}