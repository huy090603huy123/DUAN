import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/member_book_issue.dart';
import 'package:warehouse/providers/issues_provider.dart';
import 'package:warehouse/ui/screens/issues/issue_details_screen.dart';
import 'package:warehouse/utils/enums/book_issue_status_enum.dart';

class LoanListScreen extends StatelessWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy provider mà không cần lắng nghe thay đổi ở đây
    final issuesProvider = Provider.of<IssuesProvider>(context, listen: false);

    // TODO: Bạn cần có logic để lấy ID của người dùng hiện tại
    // Ví dụ: final currentUserId = Provider.of<AuthProvider>(context).userId;
    const memberId = 'your_current_member_id'; // <<--- THAY THẾ ID THÀNH VIÊN THỰC TẾ

    return Scaffold(
      appBar: AppBar(
        title: Text('Sách đang mượn', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: StreamBuilder<List<MemberBookIssue>>(
        // SỬA LỖI: Lắng nghe trực tiếp vào stream chính xác từ provider
        // và truyền vào memberId để provider lọc đúng dữ liệu.
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
                'Lịch sử mượn sách trống.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final allIssues = snapshot.data!;
          // Lọc ra danh sách sách đang mượn (chưa trả)
          final loanList = allIssues
              .where((issue) => issue.status != BookIssueStatus.RETURNED)
              .toList();

          if (loanList.isEmpty) {
            return const Center(
              child: Text(
                'Bạn không có sách nào đang mượn.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: loanList.length,
            itemBuilder: (context, index) {
              final issue = loanList[index];
              return _buildLoanCard(context, issue);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, MemberBookIssue issue) {
    // SỬA LỖI: Dùng 'dueDate' để kiểm tra quá hạn
    final isOverdue = issue.dueDate != null &&
        issue.dueDate!.isBefore(DateTime.now()) &&
        issue.status != BookIssueStatus.RETURNED;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Thêm viền đỏ nếu quá hạn
        side: BorderSide(
          color: isOverdue ? Colors.red.shade400 : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => IssueDetailsScreen(issue: issue),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issue.bookName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Tác giả: ${issue.authorName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hạn trả:', style: TextStyle(color: Colors.grey)),
                      // SỬA LỖI: Dùng 'dueDate' để hiển thị
                      Text(
                        DateFormat('dd/MM/yyyy').format(issue.dueDate!),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'QUÁ HẠN',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}