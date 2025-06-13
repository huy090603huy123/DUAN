import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/author_details_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../models/author.dart';
import '../../../models/author_details.dart';
import '../../widgets/authors/author_details_sheet.dart';

class AuthorDetailsScreen extends StatelessWidget {
  const AuthorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI: Xử lý arguments một cách an toàn
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    // Nếu không có aId được truyền vào, hiển thị lỗi và không build phần còn lại
    if (args == null || args is! int) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: const Center(
          child: Text(
            'Author ID is missing or invalid.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final int aId = args;
    final authorDetailsProvider = Provider.of<AuthorDetailsProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        // SỬA LỖI: FutureBuilder phải có kiểu khớp với kiểu trả về của future
        child: FutureBuilder<AuthorDetails?>(
          future: authorDetailsProvider.getAuthorDetails(aId),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('An error occurred!', style: TextStyle(color: Colors.white)));
            }

            // SỬA LỖI: Kiểm tra cả snapshot.hasData và snapshot.data không phải là null
            if (snapshot.hasData && snapshot.data != null) {
              final AuthorDetails authorDetails = snapshot.data!; // Bây giờ authorDetails chắc chắn không null
              final Author author = authorDetails.author;

              // SỬA LỖI: Kiểm tra xem danh sách genres có rỗng không, thay vì kiểm tra phần tử đầu tiên
              if (authorDetails.genres.isNotEmpty) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      buildAppBar(context),
                      const SizedBox(height: 30),
                      // Sử dụng LayoutBuilder hoặc ShrinkWrap để widget con có kích thước hợp lý
                      AuthorDetailsSheet(
                        authorImageUrl: author.imageUrl,
                        authorName: "${author.firstName} ${author.lastName}",
                        authorAge: author.age,
                        authorCountry: author.country,
                        authorRating: author.rating,
                        genres: authorDetails.genres,
                        books: authorDetails.books,
                      ),
                    ],
                  ),
                );
              } else {
                // Xử lý trường hợp không có genres
                return const Center(child: Text('Author has no listed genres.', style: TextStyle(color: Colors.white)));
              }
            }

            // Fallback nếu không có dữ liệu
            return const Center(child: Text('Author not found.', style: TextStyle(color: Colors.white)));
          },
        ),
      ),
    );
  }

  Padding buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white38,
              ),
            ),
          ),
          const SizedBox(width: 30),
          // SỬA LỖI: headline2 -> headlineLarge
          Text(
            "Author Details",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}