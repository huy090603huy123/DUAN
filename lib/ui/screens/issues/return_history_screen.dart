import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/member_book_issue.dart';
import 'package:warehouse/providers/issues_provider.dart';
import 'package:warehouse/providers/members_provider.dart';
import 'package:warehouse/ui/screens/issues/issue_details_screen.dart';
import 'package:warehouse/utils/enums/book_issue_status_enum.dart';

class ReturnHistoryScreen extends StatelessWidget {
  const ReturnHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy provider
    final issuesProvider = Provider.of<IssuesProvider>(context, listen: false);
    final memberId = Provider.of<MembersProvider>(context).member?.id;

    // Trường hợp người dùng chưa đăng nhập
    if (memberId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lịch sử trả sách')),
        body: const Center(
          child: Text('Vui lòng đăng nhập để xem thông tin.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử trả sách', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: StreamBuilder<List<MemberBookIssue>>(
        stream: issuesProvider.memberBookIssuesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Lịch sử trả sách của bạn trống.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final allIssues = snapshot.data!;
          // Lọc ra danh sách các phiếu đã trả của người dùng hiện tại
          final returnList = allIssues
              .where((issue) =>
          issue.userId == memberId &&
              issue.status == BookIssueStatus.RETURNED)
              .toList();

          if (returnList.isEmpty) {
            return const Center(
              child: Text(
                'Lịch sử trả sách của bạn trống.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: returnList.length,
            itemBuilder: (context, index) {
              final issue = returnList[index];
              return _buildReturnCard(context, issue);
            },
          );
        },
      ),
    );
  }

  Widget _buildReturnCard(BuildContext context, MemberBookIssue issue) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => IssueDetailsScreen(issue: issue),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Ảnh bìa sách
              SizedBox(
                width: 60,
                height: 80,
                child: issue.bookImageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    issue.bookImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.book, size: 30, color: Colors.grey),
                    ),
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.book, size: 30, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin sách
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.bookName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (issue.dueDate != null)
                      Text(
                        'Đã trả ngày: ${DateFormat('dd/MM/yyyy').format(issue.dueDate!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Icon đã trả
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}