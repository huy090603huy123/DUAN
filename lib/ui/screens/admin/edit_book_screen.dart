import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

// Import các model cần thiết
import 'package:warehouse/models/book.dart';
import 'package:warehouse/models/author.dart';
import 'package:warehouse/models/genre.dart';

// Import các provider cần thiết
import 'package:warehouse/providers/publishes_provider.dart';
import 'package:warehouse/providers/authors_provider.dart';
import 'package:warehouse/providers/genres_provider.dart';

class EditBookScreen extends StatefulWidget {
  final Book? book; // book có thể là null (chế độ thêm mới) hoặc không (chế độ sửa)

  const EditBookScreen({super.key, this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  // State để lưu dữ liệu từ các form field
  Map<String, dynamic> _formData = {
    'name': '',
    'bio': '',
    'imageUrl': '',
    'rating': 0,
    'publishedDate': null,
    'quantity': 0,
  };

  // State để lưu danh sách các ID đã được chọn
  List<String> _selectedAuthorIds = [];
  List<String> _selectedGenreIds = [];

  bool _isLoading = false;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    // Nếu là chế độ chỉnh sửa, gán dữ liệu của sách vào state
    if (widget.book != null) {
      _formData = {
        'name': widget.book!.name,
        'bio': widget.book!.bio,
        'imageUrl': widget.book!.imageUrl,
        'rating': widget.book!.rating,
        'publishedDate': widget.book!.publishedDate,
        'quantity': widget.book!.quantity,
      };
      _selectedAuthorIds = List<String>.from(widget.book!.authorIds);
      _selectedGenreIds = List<String>.from(widget.book!.genreIds);
    }
  }

  /// Mở thư viện ảnh để người dùng chọn ảnh
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
    }
  }

  /// Lưu dữ liệu từ form
  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate();
    // Kiểm tra thêm xem người dùng đã chọn tác giả và thể loại chưa
    if (isValid != true || _selectedAuthorIds.isEmpty || _selectedGenreIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đủ thông tin và chọn ít nhất một tác giả, một thể loại.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<PublishesProvider>(context, listen: false);

    try {
      _formData['publishedDate'] = DateTime.now();

      // Nếu có ảnh mới được chọn, tải nó lên Cloudinary
      if (_pickedImageFile != null) {
        final cloudinary = CloudinaryPublic('dju0kwmdv', 'my_unsigned_preset', cache: false);
        try {
          CloudinaryResponse response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(_pickedImageFile!.path, resourceType: CloudinaryResourceType.Image),
          );
          _formData['imageUrl'] = response.secureUrl;
        } catch (e) {
          throw Exception('Không thể tải ảnh lên. Vui lòng thử lại.');
        }
      } else if (widget.book == null) {
        _formData['imageUrl'] = ''; // Ảnh mặc định nếu không chọn
      }

      // Gộp dữ liệu từ form và các ID đã chọn lại thành một object
      final finalBookData = {
        ..._formData,
        'authorIds': _selectedAuthorIds,
        'genreIds': _selectedGenreIds,
      };

      if (widget.book == null) {
        await provider.addBook(finalBookData);
      } else {
        await provider.updateBook(widget.book!.id, finalBookData);
      }
      if(mounted) Navigator.of(context).pop();
    } catch (error) {
      if(mounted){
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Đã có lỗi xảy ra!'),
            content: Text('Không thể lưu dữ liệu. Lỗi: $error'),
            actions: [ TextButton(child: const Text('OK'), onPressed: () => Navigator.of(ctx).pop()) ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu từ các provider
    final authorsProvider = Provider.of<AuthorsProvider>(context);
    final genresProvider = Provider.of<GenresProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.book == null ? 'Thêm sách mới' : 'Chỉnh sửa sách'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [ IconButton(icon: const Icon(Icons.save), onPressed: _saveForm, tooltip: 'Lưu') ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12.0),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      initialValue: _formData['name'],
                      decoration: const InputDecoration(labelText: 'Tên sách', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên sách.' : null,
                      onSaved: (v) => _formData['name'] = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _formData['bio'],
                      decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                      maxLines: 3,
                      onSaved: (v) => _formData['bio'] = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _formData['quantity'].toString(),
                      decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập số lượng.';
                        if (int.tryParse(v) == null) return 'Vui lòng nhập một số hợp lệ.';
                        if (int.parse(v) < 0) return 'Số lượng không được âm.';
                        return null;
                      },
                      onSaved: (v) => _formData['quantity'] = int.tryParse(v ?? '0') ?? 0,
                    ),
                    const SizedBox(height: 24),

                    // Phần chọn tác giả
                    const Text('Tác giả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildChipSelection<Author>(
                      allItems: authorsProvider.authors,
                      selectedIds: _selectedAuthorIds,
                      onSelected: (id) {
                        setState(() {
                          _selectedAuthorIds.contains(id)
                              ? _selectedAuthorIds.remove(id)
                              : _selectedAuthorIds.add(id);
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Phần chọn thể loại
                    const Text('Thể loại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildChipSelection<Genre>(
                      allItems: genresProvider.genres,
                      selectedIds: _selectedGenreIds,
                      onSelected: (id) {
                        setState(() {
                          _selectedGenreIds.contains(id)
                              ? _selectedGenreIds.remove(id)
                              : _selectedGenreIds.add(id);
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton.icon(
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

  /// Widget con để hiển thị phần chọn ảnh
  Widget _buildImagePicker() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 100, height: 150,
          decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _pickedImageFile != null
                ? Image.file(_pickedImageFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                : (_formData['imageUrl'] != null && _formData['imageUrl'].isNotEmpty
                ? Image.network(_formData['imageUrl'], fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (c, o, s) => const Icon(Icons.image_search, color: Colors.grey, size: 40))
                : const Center(child: Text('Chọn ảnh', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Chọn ảnh từ thư viện'),
            onPressed: _pickImage,
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  /// Widget chung để hiển thị các lựa chọn (tác giả, thể loại) dưới dạng Chip
  Widget _buildChipSelection<T>({
    required List<T> allItems,
    required List<String> selectedIds,
    required Function(String) onSelected,
  }) {
    if (allItems.isEmpty) {
      String typeName = T.toString().toLowerCase();
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text('Chưa có $typeName nào. Vui lòng thêm $typeName trước.', style: TextStyle(color: Colors.grey[600])),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: allItems.map((item) {
          final dynamic itemAsDynamic = item;
          final String id = itemAsDynamic.id;
          // Kiểm tra xem đối tượng có getter 'authorName' không, nếu không thì dùng 'name'
          final String name = item is Author ? (item as Author).authorName : (itemAsDynamic.name as String);
          final bool isSelected = selectedIds.contains(id);

          return FilterChip(
            label: Text(name),
            selected: isSelected,
            onSelected: (_) => onSelected(id),
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.25),
            checkmarkColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.black87),
            backgroundColor: Colors.grey.shade200,
            shape: StadiumBorder(side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400)),
          );
        }).toList(),
      ),
    );
  }
}
