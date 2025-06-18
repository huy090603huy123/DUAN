import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/providers/publishes_provider.dart';
import 'edit_book_screen.dart';

class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final publishesProvider = Provider.of<PublishesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sách'),
        backgroundColor: Colors.indigo[800],
      ),
      body: StreamBuilder<List<Book>>(
        stream: publishesProvider.booksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có sách nào.'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (ctx, index) {
              final book = books[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                      ? NetworkImage(book.imageUrl!)
                      : null,
                  child: (book.imageUrl == null || book.imageUrl!.isEmpty)
                      ? const Icon(Icons.book)
                      : null,
                ),
                title: Text(book.name),
                subtitle: Text('ID: ${book.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditBookScreen(book: book),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Hiển thị hộp thoại xác nhận trước khi xóa
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xác nhận'),
                            content: Text('Bạn có chắc chắn muốn xóa sách "${book.name}" không?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Hủy'),
                                onPressed: () => Navigator.of(ctx).pop(false),
                              ),
                              TextButton(
                                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                onPressed: () => Navigator.of(ctx).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await publishesProvider.deleteBook(book.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã xóa sách "${book.name}"'))
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Xóa sách thất bại: $e'))
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              // Đi đến màn hình Edit/Add nhưng không truyền sách nào (tức là thêm mới)
              builder: (context) => const EditBookScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm sách mới',
      ),
    );
  }
}
