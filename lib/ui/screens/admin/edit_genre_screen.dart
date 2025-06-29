// lib/ui/screens/admin/edit_genre_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/genre.dart';
import 'package:warehouse/providers/genres_provider.dart';

class EditGenreScreen extends StatefulWidget {
  final Genre? genre;

  const EditGenreScreen({super.key, this.genre});

  @override
  State<EditGenreScreen> createState() => _EditGenreScreenState();
}

class _EditGenreScreenState extends State<EditGenreScreen> {
  final _formKey = GlobalKey<FormState>();
  String _genreName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.genre != null) {
      _genreName = widget.genre!.name;
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<GenresProvider>(context, listen: false);
    final genreData = {'name': _genreName};

    try {
      if (widget.genre == null) {
        await provider.addGenre(genreData);
      } else {
        await provider.updateGenre(widget.genre!.id, genreData);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Đã có lỗi xảy ra!'),
            content: Text('Không thể lưu dữ liệu. $error'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              )
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.genre == null ? 'Thêm Thể Loại' : 'Chỉnh Sửa Thể Loại'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                initialValue: _genreName,
                decoration: const InputDecoration(
                  labelText: 'Tên Thể Loại',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên thể loại.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _genreName = value ?? '';
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}