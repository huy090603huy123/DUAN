import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/providers/publishes_provider.dart';

class EditBookScreen extends StatefulWidget {
  // Nếu book là null, đây là màn hình "Thêm mới".
  // Nếu có giá trị, đây là màn hình "Chỉnh sửa".
  final Book? book;

  const EditBookScreen({super.key, this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  // Sử dụng một Map để lưu trữ dữ liệu form
  Map<String, dynamic> _formData = {
    'name': '',
    'bio': '',
    'imageUrl': '',
    'rating': 0,
    'publishedDate': null,
    'authorIds': <String>[],
    'genreIds': <String>[],
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      // Nếu là chế độ sửa, điền dữ liệu từ sách có sẵn vào form
      _formData = {
        'name': widget.book!.name,
        'bio': widget.book!.bio,
        'imageUrl': widget.book!.imageUrl,
        'rating': widget.book!.rating,
        'publishedDate': widget.book!.publishedDate,
        'authorIds': List<String>.from(widget.book!.authorIds),
        'genreIds': List<String>.from(widget.book!.genreIds),
      };
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    _formKey.currentState?.save(); // Lưu các giá trị từ TextFormField vào _formData

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<PublishesProvider>(context, listen: false);

    try {
      // Logic chọn ngày (tạm thời, có thể thay bằng DatePicker)
      _formData['publishedDate'] = DateTime.now();

      if (widget.book == null) {
        // Chế độ Thêm mới
        await provider.addBook(_formData);
      } else {
        // Chế độ Cập nhật
        await provider.updateBook(widget.book!.id, _formData);
      }
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đã có lỗi xảy ra!'),
          content: Text('Không thể lưu dữ liệu. Vui lòng thử lại.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
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
      appBar: AppBar(
        title: Text(widget.book == null ? 'Thêm sách mới' : 'Chỉnh sửa sách'),
        backgroundColor: Colors.indigo[800],
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _formData['name'],
                  decoration: const InputDecoration(labelText: 'Tên sách'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên sách.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _formData['name'] = value ?? '';
                  },
                ),
                TextFormField(
                  initialValue: _formData['bio'],
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                  onSaved: (value) {
                    _formData['bio'] = value ?? '';
                  },
                ),
                TextFormField(
                  initialValue: _formData['imageUrl'],
                  decoration: const InputDecoration(labelText: 'URL Hình ảnh'),
                  onSaved: (value) {
                    _formData['imageUrl'] = value ?? '';
                  },
                ),
                // TODO: Bổ sung các widget để chọn tác giả và thể loại
                // (ví dụ: MultiSelectDialogField)
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(widget.book == null ? 'Thêm mới' : 'Cập nhật'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
