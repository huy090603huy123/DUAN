import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/publishes_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../widgets/collections/book_collections_sheet.dart';
import '../../widgets/books/books_list.dart';
import '../../widgets/collections/top_authors_list.dart';

class BookCollectionsScreen extends StatefulWidget {
  const BookCollectionsScreen({super.key});

  @override
  State<BookCollectionsScreen> createState() => _BookCollectionsScreenState();
}

class _BookCollectionsScreenState extends State<BookCollectionsScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  // SỬA LỖI: Khởi tạo giá trị ban đầu cho biến.
  bool isSearchActive = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng màu nền từ Theme để nhất quán
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              //Title
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
                  child: Text(
                    "Libreasy",
                    // SỬA LỖI: headline1 -> displayLarge
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
                child: TextField(
                  // SỬA LỖI: Sửa lại logic bên trong setState để không trả về giá trị
                  onChanged: (val) {
                    setState(() {
                      isSearchActive = val.isNotEmpty;
                    });
                  },
                  keyboardType: TextInputType.name,
                  controller: _textEditingController,
                  cursorColor: Theme.of(context).primaryColor,
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(17),
                    filled: true,
                    fillColor: Colors.blue[900],
                    hintText: "What would you like to read?",
                    hintStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.4,
                        style: BorderStyle.solid,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              //Conditional UI: Hiển thị kết quả tìm kiếm hoặc màn hình chính
              if (isSearchActive)
                BookSearchSheet(searchTerm: _textEditingController.text.trim())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Top Authors title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
                      child: const Text(
                        "Top Authors",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    //Top Authors list
                    Consumer<PublishesProvider>(
                      builder: (_, pubProv, __) => TopAuthorsList(
                        authors: pubProv.authors,
                      ),
                    ),

                    const SizedBox(height: 10),

                    //Collections Container
                     BookCollectionsSheet(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookSearchSheet extends StatelessWidget {
  final String searchTerm;

  // SỬA LỖI: Cập nhật cú pháp constructor cho đúng chuẩn null safety.
  const BookSearchSheet({
    super.key,
    required this.searchTerm,
  });

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
      // Giới hạn chiều cao để tránh lỗi overflow
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),

          //Search results title
          buildCollectionName("Search Results", context),

          const SizedBox(height: 10),

          //Filtered books list
          Expanded(
            child: Consumer<PublishesProvider>(
              builder: (ctx, pubProv, child) {
                // Lọc danh sách sách dựa trên searchTerm
                final filteredBooks = pubProv.books
                    .where((book) => book.name.toLowerCase().contains(searchTerm.toLowerCase()))
                    .toList();
                return BooksList(books: filteredBooks);
              },
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}