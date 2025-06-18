import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/utils/enums/status_enum.dart';

import '../../../providers/author_details_provider.dart';
 // Giả sử DataRepository ở đây
import '../../../services/repositories/data_repository.dart';
import '../../../utils/helper.dart';
import '../../../models/author.dart';
import '../../widgets/authors/author_details_sheet.dart';

class AuthorDetailsScreen extends StatelessWidget {
  const AuthorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    // SỬA LỖI: ID của Firestore là String, không phải int.
    if (args == null || args is! String) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Author ID is missing or invalid.')),
      );
    }

    final String authorId = args;

    // SỬA LỖI: Sử dụng ChangeNotifierProvider để tạo và cung cấp provider
    // chỉ cho màn hình này và các widget con của nó.
    return ChangeNotifierProvider<AuthorDetailsProvider>(
      create: (context) => AuthorDetailsProvider(
        dataRepository: Provider.of<DataRepository>(context, listen: false),
        authorId: authorId,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Tách AppBar ra để nó không bị build lại liên tục
              buildAppBar(context),
              Expanded(
                // Consumer sẽ chỉ build lại phần nội dung chính
                child: Consumer<AuthorDetailsProvider>(
                  builder: (context, provider, _) {
                    // Xử lý các trạng thái của provider
                    switch (provider.status) {
                      case Status.LOADING:
                      case Status.INITIAL:
                        return const Center(child: CircularProgressIndicator());
                      case Status.ERROR:
                        return const Center(child: Text('Failed to load details.'));
                      case Status.DONE:
                        final author = provider.author;
                        if (author == null) {
                          return const Center(child: Text('Author not found.'));
                        }

                        // Build giao diện chính khi đã có dữ liệu
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              // Dùng StreamBuilder để hiển thị danh sách sách
                              StreamBuilder<List<Book>>(
                                stream: provider.booksStream,
                                builder: (context, snapshot) {
                                  // Lấy danh sách sách, hoặc một danh sách rỗng nếu stream chưa có dữ liệu
                                  final books = snapshot.data ?? [];

                                  // NOTE: Giả định AuthorDetailsSheet đã được cập nhật
                                  // để nhận dữ liệu theo cách mới.
                                  return AuthorDetailsSheet(
                                    authorImageUrl: author.imageUrl ?? Helper.bookPlaceholder,
                                    authorName: author.authorName,
                                    // SỬA LỖI: Truy cập thuộc tính 'age'
                                    authorAge: author.age,
                                    // SỬA LỖI: Xử lý giá trị có thể null
                                    authorCountry: author.country ?? 'Unknown',
                                    authorRating: author.rating,
                                    // Chuyển danh sách sách vào sheet
                                    books: books,
                                    // NOTE: Lấy genres từ sách. Logic này có thể cần
                                    // được tối ưu hóa trong provider.
                                    genres: const [], // Tạm thời để trống
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      default:
                        return const Center(child: Text('Something went wrong.'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding, vertical: 10),
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
          Text(
            "Author Details",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
