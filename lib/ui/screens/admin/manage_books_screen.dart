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
      // SỬA LỖI: Thêm màu nền sáng để khắc phục lỗi nền đen
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản lý Sách'),
        // THIẾT KẾ LẠI: Thêm hiệu ứng gradient cho AppBar để đồng bộ
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_online_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Chưa có sách nào', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          final books = snapshot.data!;
          // THIẾT KẾ LẠI: Sử dụng ListView.separated để có khoảng cách giữa các Card
          return ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: books.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final book = books[index];
              // THIẾT KẾ LẠI: Bọc mỗi mục trong một Card
              return Card(
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                          ? Image.network(
                        book.imageUrl!,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 40),
                      )
                          : Container(
                        width: 50,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                    ),
                    title: Text(book.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Số lượng: ${book.quantity}', style: TextStyle(color: Colors.grey.shade600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditBookScreen(book: book),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _showDeleteConfirmation(context, publishesProvider, book),
                        ),
                      ],
                    ),
                  ),
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
              builder: (context) => const EditBookScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Thêm sách mới',
      ),
    );
  }

  // Tách hàm xác nhận xóa ra cho gọn gàng
  void _showDeleteConfirmation(BuildContext context, PublishesProvider provider, Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sách "${book.name}" không? Thao tác này không thể hoàn tác.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await provider.deleteBook(book.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã xóa sách "${book.name}"'), backgroundColor: Colors.green)
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Xóa sách thất bại: $e'), backgroundColor: Colors.red)
          );
        }
      }
    }
  }
}