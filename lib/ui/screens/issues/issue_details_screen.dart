import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse/models/member_book_issue.dart';
import 'package:warehouse/utils/enums/book_issue_status_enum.dart';

class IssueDetailsScreen extends StatelessWidget {
  final MemberBookIssue issue;

  const IssueDetailsScreen({super.key, required this.issue});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa cập nhật';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Phiếu', style: textTheme.titleLarge),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin sách', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      height: 70,
                      child: issue.bookImageUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          issue.bookImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.book, size: 40),
                        ),
                      )
                          : Icon(Icons.book, color: primaryColor, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(issue.bookName, style: textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text('Tác giả: ${issue.authorName}', style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Thông tin mượn/trả', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow('Mã phiếu:', issue.id, textTheme),
                    _buildDetailRow('Ngày mượn:', _formatDate(issue.issueDate), textTheme),
                    _buildDetailRow('Hạn trả:', _formatDate(issue.dueDate), textTheme),
                    // Code này sẽ chạy đúng vì issue.status là Enum và
                    // issue.actualReturnDate đã tồn tại trong model



                    // Code này sẽ chạy đúng vì issue.status là Enum

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}