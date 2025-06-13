import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/genres_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../common/search_textfield.dart';
import '../books/genres_books_list.dart';

class BookListingsSheet extends StatefulWidget {
  final PageController genreController;

  // SỬA LỖI: Cập nhật cú pháp constructor cho đúng chuẩn null safety.
  const BookListingsSheet({
    super.key,
    required this.genreController,
  });

  @override
  State<BookListingsSheet> createState() => _BookListingsSheetState();
}

class _BookListingsSheetState extends State<BookListingsSheet> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final genreProvider = Provider.of<GenresProvider>(context);

    return Expanded(
      child: Container(
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
            const SizedBox(height: 20),

            //Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SearchTextField(
                fillColor: Colors.blueGrey.shade50,
                inputTextColor: Theme.of(context).primaryColor,
                hintTextColor: Colors.black38,
                controller: _textEditingController,
                onChanged: (val) => setState(() {}),
              ),
            ),

            const SizedBox(height: 20),

            //Books list
            Expanded(
              child: PageView.builder(
                controller: widget.genreController,
                itemCount: genreProvider.genres.length,
                onPageChanged: genreProvider.setActiveIndex,
                itemBuilder: (ctx, i) {
                  // Cải thiện logic: Truyền ID của genre tương ứng với trang hiện tại
                  final genre = genreProvider.genres[i];
                  return GenreBooksList(
                    gId: genre.id,
                    searchTerm: _textEditingController.text.trim(),
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
