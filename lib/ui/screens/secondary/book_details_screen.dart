import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/author.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/models/genre.dart';
import 'package:warehouse/models/book_review.dart';
import 'package:warehouse/providers/members_provider.dart';
import 'package:warehouse/services/repositories/data_repository.dart';
import 'package:warehouse/utils/enums/status_enum.dart';

import '../../../providers/issues_provider.dart';
import '../../../providers/book_details_provider.dart';
import '../../../utils/helper.dart';
import '../../widgets/common/bottom_button_bar.dart';
import '../../widgets/books/book_details_sheet.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! String) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Thiếu hoặc ID sách không hợp lệ.')),
      );
    }

    final String bookId = args;

    // Cung cấp các provider cần thiết cho màn hình này
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BookDetailsProvider>(
          create: (context) => BookDetailsProvider(
            dataRepository: DataRepository.instance,
            bookId: bookId,
          ),
        ),
        ChangeNotifierProxyProvider<MembersProvider, IssuesProvider>(
          create: (context) => IssuesProvider(
            dataRepository: DataRepository.instance,
            userId: Provider.of<MembersProvider>(context, listen: false).member!.id,
          ),
          update: (context, membersProvider, _) => IssuesProvider(
            dataRepository: DataRepository.instance,
            userId: membersProvider.member!.id,
          ),
        ),
      ],
      child: Consumer<BookDetailsProvider>(
        builder: (context, bookDetailsProvider, _) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: _buildContent(context, bookDetailsProvider),
            ),
            bottomNavigationBar: _buildBottomBar(context, bookDetailsProvider),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookDetailsProvider provider) {
    switch (provider.status) {
      case Status.LOADING:
      case Status.INITIAL:
        return const Center(child: CircularProgressIndicator());
      case Status.ERROR:
        return const Center(child: Text('Không thể tải chi tiết sách.'));
      case Status.DONE:
        final book = provider.book;
        if (book == null) {
          return const Center(child: Text('Không tìm thấy sách.'));
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildAppBar(context, book.name),
              const SizedBox(height: 30),
              BookDetailsSheet(
                bookTitle: book.name,
                // SỬA LỖI: Sử dụng đúng tên tham số là 'bookAuthor'
                bookAuthor: provider.authors,
                bookImageUrl: book.imageUrl ?? Helper.bookPlaceholder,
                bookBio: book.bio,
                bookPublishedDate:
                Helper.datePresenter(book.publishedDate) ?? 'N/A',
                bookRating: book.rating,
                genres: provider.genres,
              ),
            ],
          ),
        );
      default:
        return const Center(child: Text('Đã có lỗi xảy ra.'));
    }
  }

  Widget _buildBottomBar(BuildContext context, BookDetailsProvider provider) {
    if (provider.status == Status.DONE && provider.book != null) {
      final book = provider.book!;
      return BottomButtonBar(
        label: "MƯỢN SÁCH",
        onPressed: () async {
          final issueProvider = Provider.of<IssuesProvider>(context, listen: false);
          final membersProvider = Provider.of<MembersProvider>(context, listen: false);

          if (!membersProvider.isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng đăng nhập để mượn sách.')),
            );
            return;
          }

          final bool borrowed = await issueProvider.issueBook(
            bookId: book.id,
            userId: membersProvider.member!.id,
            bookDetails: book,
            // Tham số 'authors' đã được loại bỏ chính xác
          );

          if (!context.mounted) return;
          showModalBottomSheet(
            context: context,
            builder: (_) => _buildBorrowStatusSheet(borrowed),
          );
        },
      );
    } else {
      return BottomButtonBar(
        label: "MƯỢN SÁCH",
        onPressed: () {},
        color: Colors.grey.shade400,
      );
    }
  }

  Widget _buildBorrowStatusSheet(bool borrowed) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Divider(color: Colors.grey[400], height: 25),
          const SizedBox(height: 30),
          Icon(
            borrowed ? Icons.check_circle : Icons.cancel,
            color: borrowed ? Colors.green : Colors.red,
            size: 85,
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              borrowed
                  ? "Bạn đã mượn thành công cuốn sách này trong 1 tháng"
                  : "Mượn sách thất bại. Sách có thể đã hết.",
              style: const TextStyle(fontSize: 21, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Padding buildAppBar(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
              child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white38),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
