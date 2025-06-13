import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/issues_provider.dart';
import '../../../providers/book_details_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../models/book_details.dart';
import '../../../models/book.dart';
import '../../widgets/common/bottom_button_bar.dart';
import '../../widgets/books/book_details_sheet.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI: Xử lý arguments một cách an toàn
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! int) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: const Center(
          child: Text(
            'Book ID is missing or invalid.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final int bkId = args;
    final bookDetailsProvider = Provider.of<BookDetailsProvider>(context, listen: false);
    final issueProvider = Provider.of<IssuesProvider>(context, listen: false);
    final future = bookDetailsProvider.getBookDetails(bkId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<BookDetails?>(
          future: future,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('An error occurred!', style: TextStyle(color: Colors.white)));
            }
            if (snapshot.hasData && snapshot.data != null) {
              final BookDetails bookDetails = snapshot.data!;
              final Book book = bookDetails.book;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    buildAppBar(context),
                    const SizedBox(height: 30),
                    BookDetailsSheet(
                      bookTitle: book.name,
                      bookAuthor: bookDetails.authors,
                      bookImageUrl: book.imageUrl,
                      bookBio: book.bio,
                      bookPublishedDate: Helper.datePresenter(book.publishedDate) ?? 'N/A',
                      bookRating: book.rating,
                      genres: bookDetails.genres,
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Book not found.', style: TextStyle(color: Colors.white)));
          },
        ),
      ),
      bottomNavigationBar: FutureBuilder<BookDetails?>(
        future: future,
        builder: (ctx, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final BookDetails bookDetails = snapshot.data!;
            return BottomButtonBar(
                label: "BORROW",
                onPressed: () async {
                  final bool borrowed = await issueProvider.issueBook(bkId, bookDetails);

                  if (!context.mounted) return;
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    builder: (_) => Container(
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
                          Divider(
                            color: Colors.grey[400],
                            height: 25,
                          ),
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
                                  ? "This book has been issued for 1 month"
                                  : "This book is currently not available for issue",
                              style: const TextStyle(
                                fontSize: 21,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return BottomButtonBar(
              label: "BORROW",
              onPressed: () {},
              color: Colors.grey.shade400,
            );
          }
        },
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
            "Book Details",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}