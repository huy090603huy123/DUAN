import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/providers/publishes_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class EditBookScreen extends StatefulWidget {
  final Book? book;

  const EditBookScreen({super.key, this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {
    'name': '',
    'bio': '',
    'imageUrl': '',
    'rating': 0,
    'publishedDate': null,
    'quantity': 0,
    'authorIds': <String>[],
    'genreIds': <String>[],
  };
  bool _isLoading = false;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _formData = {
        'name': widget.book!.name,
        'bio': widget.book!.bio,
        'imageUrl': widget.book!.imageUrl,
        'rating': widget.book!.rating,
        'publishedDate': widget.book!.publishedDate,
        'quantity': widget.book!.quantity,
        'authorIds': List<String>.from(widget.book!.authorIds),
        'genreIds': List<String>.from(widget.book!.genreIds),
      };
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
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

    final provider = Provider.of<PublishesProvider>(context, listen: false);

    try {
      _formData['publishedDate'] = DateTime.now();

      if (_pickedImageFile != null) {
        final cloudinary = CloudinaryPublic(
          'dju0kwmdv', // Thay bằng Cloud Name của bạn
          'my_unsigned_preset', // Thay bằng upload preset của bạn
          cache: false,
        );

        try {
          CloudinaryResponse response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(_pickedImageFile!.path, resourceType: CloudinaryResourceType.Image),
          );
          _formData['imageUrl'] = response.secureUrl;
        } on CloudinaryException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tải ảnh thất bại: ${e.message}'), backgroundColor: Colors.red)
            );
          }
          throw Exception('Không thể tải ảnh lên Cloudinary.');
        }
      } else if (widget.book == null) {
        _formData['imageUrl'] = ''; // Hoặc một URL ảnh mặc định
      }

      if (widget.book == null) {
        await provider.addBook(_formData);
      } else {
        await provider.updateBook(widget.book!.id, _formData);
      }
      if(mounted) Navigator.of(context).pop();
    } catch (error) {
      if(mounted){
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
      // SỬA LỖI: Thêm màu nền sáng để khắc phục lỗi nền đen
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.book == null ? 'Thêm sách mới' : 'Chỉnh sửa sách'),
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
        padding: const EdgeInsets.all(12.0),
        // THIẾT KẾ LẠI: Bọc Form trong một Card để có nền trắng và đổ bóng
        child: Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      initialValue: _formData['name'],
                      decoration: const InputDecoration(labelText: 'Tên sách', border: OutlineInputBorder()),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _formData['bio'],
                      decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                      maxLines: 3,
                      onSaved: (value) {
                        _formData['bio'] = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _pickedImageFile != null
                                ? Image.file(
                              _pickedImageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                                : (_formData['imageUrl'] != null && _formData['imageUrl'].isNotEmpty
                                ? Image.network(
                              _formData['imageUrl'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                                : const Center(child: Text('Chưa có ảnh', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.image_search),
                            label: const Text('Chọn ảnh từ thư viện'),
                            onPressed: _pickImage,
                            style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _formData['quantity'].toString(),
                      decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập số lượng.';
                        if (int.tryParse(value) == null) return 'Vui lòng nhập một số hợp lệ.';
                        if (int.parse(value) < 0) return 'Số lượng không được âm.';
                        return null;
                      },
                      onSaved: (value) {
                        _formData['quantity'] = int.tryParse(value ?? '0') ?? 0;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_as),
                      onPressed: _saveForm,
                      label: Text(widget.book == null ? 'Thêm mới' : 'Cập nhật'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}