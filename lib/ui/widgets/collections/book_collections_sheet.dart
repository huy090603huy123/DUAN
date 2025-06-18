import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/publishes_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../models/book.dart';
import 'book_collections_list.dart';

class BookCollectionsSheet extends StatelessWidget {
  const BookCollectionsSheet({super.key});

  Padding buildCollectionName(String text, BuildContext context, {bool author = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
      child: Text(
        text,
        style: author
            ? const TextStyle(color: Colors.white, fontSize: 20)
        // SỬA LỖI: headline3 -> titleLarge
            : Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      // Bọc trong SingleChildScrollView để tránh lỗi overflow
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),

            //New collections title
            buildCollectionName("SẢN PHẨM MỚI", context),

            const SizedBox(height: 10),

            //New collections list
            Consumer<PublishesProvider>(
              builder: (ctx, pubProv, child) => StreamBuilder<List<Book>>(
                stream: pubProv.getTop5NewBooks(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("An error occurred."));
                  }
                  // SỬA LỖI: Xử lý dữ liệu một cách an toàn
                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return BookCollectionList(
                      books: snapshot.data!,
                    );
                  }
                  return const SizedBox(
                    height: 100,
                    child: Center(child: Text("No new books found.")),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            //Top Rated title
            buildCollectionName("SẢN PHẨM NỔI BẬT", context),

            const SizedBox(height: 10),

            //Top Rated list
            Consumer<PublishesProvider>(
              builder: (ctx, pubProv, child) => StreamBuilder<List<Book>>(
                stream: pubProv.getTop5RatedBooks(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("An error occurred."));
                  }
                  // SỬA LỖI: Xử lý dữ liệu một cách an toàn
                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return BookCollectionList(
                      books: snapshot.data!,
                    );
                  }
                  return const SizedBox(
                    height: 100,
                    child: Center(child: Text("No rated books found.")),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}