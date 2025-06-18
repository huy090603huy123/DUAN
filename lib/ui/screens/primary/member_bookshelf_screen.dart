import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/issues_provider.dart';
import '../../../utils/helper.dart';
import '../../../utils/enums/book_issue_status_enum.dart';
import '../../../models/member_book_issue.dart';
import '../../widgets/common/ratings.dart'; // Import ratings widget

class MemberBookshelfScreen extends StatelessWidget {
  const MemberBookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final issuesProvider = Provider.of<IssuesProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
                child: Text(
                  "Lịch sử Mượn Trả",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<MemberBookIssue>>(
                stream: issuesProvider.memberBookIssuesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                          "Bạn chưa mượn cuốn sách nào.",
                          style: TextStyle(color: Colors.white),
                        ));
                  }
                  final myBookIssues = snapshot.data!;
                  return MyBorrowsList(
                    myBookIssues: myBookIssues,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyBorrowsList extends StatelessWidget {
  final List<MemberBookIssue> myBookIssues;

  const MyBorrowsList({super.key, required this.myBookIssues});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: myBookIssues.length,
      itemBuilder: (ctx, i) {
        final issue = myBookIssues[i];
        return BorrowListItem(issue: issue);
      },
    );
  }
}

class BorrowListItem extends StatelessWidget {
  final MemberBookIssue issue;

  const BorrowListItem({super.key, required this.issue});

  // Chuyển đổi String thành Enum bên trong widget
  BookIssueStatus get status => BookIssueStatus.fromString(issue.status);

  // --- UI TRẢ SÁCH BẮT ĐẦU TỪ ĐÂY ---
  /// Hiển thị một bottom sheet để người dùng đánh giá và trả sách.
  void _showReturnSheet(BuildContext context) {
    final reviewController = TextEditingController();
    int currentRating = 0; // Điểm đánh giá ban đầu

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép sheet cao hơn khi bàn phím hiện
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Đánh giá sách "${issue.bookName}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              // Widget để chọn sao đánh giá
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Ratings(
                    rating: currentRating,
                    itemSize: 40,
                    onRatingUpdate: (rating) {
                      setState(() {
                        currentRating = rating.toInt();
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Viết nhận xét của bạn (tùy chọn)',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  final provider = Provider.of<IssuesProvider>(context, listen: false);
                  final success = await provider.returnBook(
                    issueId: issue.id,
                    bookId: issue.bookId,
                    rating: currentRating,
                    review: reviewController.text.trim(),
                  );
                  Navigator.of(ctx).pop(); // Đóng bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? "Trả sách thành công!" : "Trả sách thất bại.")),
                  );
                },
                child: const Text('Xác nhận Trả sách'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  // --- UI TRẢ SÁCH KẾT THÚC Ở ĐÂY ---

  @override
  Widget build(BuildContext context) {
    final issueStatus = status;
    bool isReturned = issueStatus == BookIssueStatus.RETURNED;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              issue.bookImageUrl,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(
                  width: 100,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.book_outlined, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.bookName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "bởi ${issue.authorName}",
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text("Ngày mượn: ${Helper.datePresenter(issue.issueDate) ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                    Text(isReturned ? "Ngày trả: ${Helper.datePresenter(issue.returnDate) ?? 'N/A'}" : "Hạn trả: ${Helper.datePresenter(issue.dueDate) ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    // Hiển thị nút trả sách nếu sách chưa được trả
                    if (!isReturned)
                      ElevatedButton(
                        onPressed: () => _showReturnSheet(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Trả thiết bị'),
                      )
                  ],
                ),
              ),
            ),
            Container(
              width: 35,
              color: isReturned
                  ? Colors.green
                  : (issueStatus == BookIssueStatus.OVERDUE
                  ? Colors.red
                  : Colors.orange),
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    isReturned
                        ? 'ĐÃ TRẢ'
                        : (issueStatus == BookIssueStatus.OVERDUE
                        ? 'QUÁ HẠN'
                        : 'ĐANG MƯỢN'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
