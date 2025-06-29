// lib/ui/screens/admin/manage_genres_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/genre.dart';
import 'package:warehouse/providers/genres_provider.dart';
import 'edit_genre_screen.dart';

class ManageGenresScreen extends StatelessWidget {
  const ManageGenresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Chúng ta sử dụng Consumer ở đây để nó tự build lại khi có thay đổi
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản lý Thể Loại'),
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
      body: Consumer<GenresProvider>(
        builder: (context, genreProvider, child) {
          final genres = genreProvider.genres;

          if (genres.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Chưa có thể loại nào', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: genres.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final genre = genres[index];
              return Card(
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.category, color: Theme.of(context).primaryColor),
                  ),
                  title: Text(genre.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditGenreScreen(genre: genre),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _showDeleteConfirmation(context, genreProvider, genre),
                      ),
                    ],
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
              builder: (context) => const EditGenreScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Thêm thể loại mới',
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, GenresProvider provider, Genre genre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thể loại "${genre.name}" không?'),
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
        await provider.deleteGenre(genre.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã xóa thể loại "${genre.name}"'), backgroundColor: Colors.green)
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Xóa thể loại thất bại: $e'), backgroundColor: Colors.red)
          );
        }
      }
    }
  }
}