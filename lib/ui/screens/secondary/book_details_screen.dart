/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/models/borrow_request.dart'; // THÊM: Import model cho yêu cầu mượn
import 'package:warehouse/providers/members_provider.dart';
import 'package:warehouse/services/repositories/data_repository.dart';
import 'package:warehouse/utils/enums/status_enum.dart';
import 'package:warehouse/providers/issues_provider.dart';
import 'package:warehouse/providers/book_details_provider.dart';
import 'package:warehouse/utils/helper.dart';
import 'package:warehouse/ui/widgets/common/bottom_button_bar.dart';
import 'package:warehouse/ui/widgets/books/book_details_sheet.dart';

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
            userId: Provider.of<MembersProvider>(context, listen: false).member?.id ?? '',
          ),
          update: (context, membersProvider, _) => IssuesProvider(
            dataRepository: DataRepository.instance,
            userId: membersProvider.member?.id ?? '',
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
        return const Center(child: Text('Lỗi: Không thể tải chi tiết sách.'));
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
                bookAuthor: provider.authors,
                bookImageUrl: book.imageUrl,
                bookBio: book.bio,
                bookPublishedDate: Helper.datePresenter(book.publishedDate) ?? 'N/A',
                bookRating: book.rating,
                genres: provider.genres,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Số lượng còn lại: ${book.quantity}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: book.quantity > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const Center(child: Text('Đã có lỗi xảy ra.'));
    }
  }

  Widget _buildBottomBar(BuildContext context, BookDetailsProvider provider) {
    final book = provider.book;
    final bool canBorrow = provider.status == Status.DONE && book != null && book.quantity > 0;

    // SỬA ĐỔI: Chuyển từ mượn trực tiếp sang gửi yêu cầu
    void handleSendRequest() async {
      final membersProvider = Provider.of<MembersProvider>(context, listen: false);

      if (!membersProvider.isLoggedIn || membersProvider.member == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để gửi yêu cầu.')),
        );
        return;
      }

      final newRequest = BorrowRequest(
        bookId: book!.id,
        userId: membersProvider.member!.id,
        bookTitle: book.name,
        userName: membersProvider.member!.memberName,
        bookImage: book.imageUrl,
        requestDate: DateTime.now(),
        status: RequestStatus.pending,
      );

      String message = '';
      bool success = false;
      try {
        await DataRepository.instance.createBorrowRequest(newRequest.toMap());
        message = 'Yêu cầu mượn sách đã được gửi. Vui lòng chờ admin duyệt.';
        success = true;
      } catch (e) {
        message = 'Gửi yêu cầu thất bại: ${e.toString()}';
        success = false;
      }

      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (_) => _buildBorrowStatusSheet(success, message),
      );
    }

    return BottomButtonBar(
      label: canBorrow ? "GỬI YÊU CẦU MƯỢN" : "ĐÃ HẾT SÁCH",
      color: canBorrow ? Theme.of(context).primaryColor : Colors.grey.shade600,
      onPressed: canBorrow ? handleSendRequest : () {},
    );
  }

  Widget _buildBorrowStatusSheet(bool success, String message) {
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
            success ? Icons.check_circle : Icons.cancel,
            color: success ? Colors.green : Colors.red,
            size: 85,
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              message,
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

*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Cần cho hiệu ứng làm mờ

import 'package:warehouse/models/borrow_request.dart';
import 'package:warehouse/providers/book_details_provider.dart';
import 'package:warehouse/providers/issues_provider.dart';
import 'package:warehouse/providers/members_provider.dart';
import 'package:warehouse/services/repositories/data_repository.dart';
import 'package:warehouse/utils/enums/status_enum.dart';
import 'package:warehouse/utils/helper.dart';

// Các widget tùy chỉnh
import 'package:warehouse/ui/widgets/common/ratings.dart';

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
            userId: Provider.of<MembersProvider>(context, listen: false).member?.id ?? '',
          ),
          update: (context, membersProvider, _) => IssuesProvider(
            dataRepository: DataRepository.instance,
            userId: membersProvider.member?.id ?? '',
          ),
        ),
      ],
      child: Consumer<BookDetailsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: _buildBody(context, provider),
            bottomNavigationBar: _buildBottomBar(context, provider), // Đảm bảo có bottom bar
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookDetailsProvider provider) {
    switch (provider.status) {
      case Status.LOADING:
      case Status.INITIAL:
        return const Center(child: CircularProgressIndicator());
      case Status.ERROR:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Lỗi: Không thể tải chi tiết sách. Vui lòng thử lại.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      case Status.DONE:
        final book = provider.book;
        if (book == null) {
          return const Center(child: Text('Không tìm thấy sách.'));
        }
        return Stack(
          children: [
            _buildBackgroundImage(context, book.imageUrl, book.name, provider.authors.map((a) => a.authorName).join(', ')),
            _buildDraggableSheet(context, provider),
            _buildBackButton(context),
          ],
        );
      default:
        return const Center(child: Text('Đã có lỗi xảy ra.'));
    }
  }

  Widget _buildBackgroundImage(BuildContext context, String imageUrl, String title, String authors) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            onError: (err, stack) {},
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.1)],
              begin: Alignment.bottomCenter,
              end: Alignment.center,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(color: Colors.black54, offset: Offset(1, 2), blurRadius: 4),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'bởi $authors',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableSheet(BuildContext context, BookDetailsProvider provider) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        final book = provider.book!;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              children: [

                const Divider(height: 40),
                _buildSectionTitle(context, 'Thể loại'),
                const SizedBox(height: 12),
                _buildGenreChips(context, provider.genres),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Mô tả sách'),
                const SizedBox(height: 12),
                Text(
                  book.bio,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Thông tin chi tiết'),
                const SizedBox(height: 12),
                _buildDetailRow(context, 'Ngày xuất bản', Helper.datePresenter(book.publishedDate) ?? 'N/A'),
                _buildDetailRow(context, 'Nhà xuất bản', '...'), // Cần thêm dữ liệu
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsBar(BuildContext context, double rating, int quantity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, Icons.star_rounded, 'Đánh giá', '${rating.toStringAsFixed(1)}/5'),
        _buildStatItem(context, Icons.book_online_outlined, 'Số lượng', '$quantity'),
        _buildStatItem(context, Icons.language, 'Ngôn ngữ', 'Tiếng Việt'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildGenreChips(BuildContext context, List<dynamic> genres) {
    if (genres.isEmpty) return const Text('Chưa có thông tin.');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) => Chip(
        label: Text(genre.name), // ĐÃ SỬA LỖI Ở ĐÂY
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: const StadiumBorder(),
      )).toList(),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.2),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, BookDetailsProvider provider) {
    final book = provider.book;
    final bool canBorrow = provider.status == Status.DONE && book != null && book.quantity > 0;

    void handleSendRequest() async {
      final membersProvider = Provider.of<MembersProvider>(context, listen: false);

      if (!membersProvider.isLoggedIn || membersProvider.member == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để gửi yêu cầu.')),
        );
        return;
      }

      final newRequest = BorrowRequest(
        bookId: book!.id,
        userId: membersProvider.member!.id,
        bookTitle: book.name,
        userName: membersProvider.member!.memberName,
        bookImage: book.imageUrl,
        requestDate: DateTime.now(),
        status: RequestStatus.pending,
      );

      String message = '';
      bool success = false;
      try {
        await DataRepository.instance.createBorrowRequest(newRequest.toMap());
        message = 'Yêu cầu mượn sách đã được gửi. Vui lòng chờ admin duyệt.';
        success = true;
      } catch (e) {
        message = 'Gửi yêu cầu thất bại: ${e.toString()}';
        success = false;
      }

      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (_) => _buildBorrowStatusSheet(context, success, message),
      );
    }

    // Nút Gửi yêu cầu
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canBorrow ? Theme.of(context).primaryColor : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          onPressed: canBorrow ? handleSendRequest : null,
          child: Text(
            canBorrow ? "GỬI YÊU CẦU MƯỢN" : "ĐÃ HẾT SÁCH",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBorrowStatusSheet(BuildContext context, bool success, String message) {
    return Container(
      height: 320,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.highlight_off,
            color: success ? Colors.green : Colors.red,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            success ? 'Thành Công!' : 'Thất Bại!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}