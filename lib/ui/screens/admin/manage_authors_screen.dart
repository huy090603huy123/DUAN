import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/author.dart';
import 'package:warehouse/providers/publishes_provider.dart';
import 'edit_author_screen.dart'; // Ta sẽ tạo file này ở bước tiếp theo

class ManageAuthorsScreen extends StatelessWidget {
  const ManageAuthorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final publishesProvider = Provider.of<PublishesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tác giả'),
        backgroundColor: Colors.indigo[800],
      ),
      body: StreamBuilder<List<Author>>(
        stream: publishesProvider.authorsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có tác giả nào.'));
          }

          final authors = snapshot.data!;
          return ListView.builder(
            itemCount: authors.length,
            itemBuilder: (ctx, index) {
              final author = authors[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (author.imageUrl != null && author.imageUrl!.isNotEmpty)
                      ? NetworkImage(author.imageUrl!)
                      : null,
                  child: (author.imageUrl == null || author.imageUrl!.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(author.authorName),
                subtitle: Text('ID: ${author.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditAuthorScreen(author: author),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // TODO: Thêm logic xóa tác giả (sẽ làm ở bước sau)
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
              builder: (context) => const EditAuthorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm tác giả mới',
      ),
    );
  }
}
