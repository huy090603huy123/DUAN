import 'package:flutter/material.dart';
import 'package:warehouse/models/author.dart';

class EditAuthorScreen extends StatefulWidget {
  final Author? author;

  const EditAuthorScreen({super.key, this.author});

  @override
  State<EditAuthorScreen> createState() => _EditAuthorScreenState();
}

class _EditAuthorScreenState extends State<EditAuthorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _countryController;
  late TextEditingController _ageController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.author?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.author?.lastName ?? '');
    _countryController = TextEditingController(text: widget.author?.country ?? '');
    _ageController = TextEditingController(text: widget.author?.age.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.author?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _ageController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) {
      return;
    }
    // TODO: Thêm logic để lưu dữ liệu vào Firestore (sẽ làm ở bước sau)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.author == null ? 'Thêm tác giả mới' : 'Chỉnh sửa tác giả'),
        backgroundColor: Colors.indigo[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên.' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Họ'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập họ.' : null,
                ),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(labelText: 'Quốc gia'),
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Tuổi'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL Hình ảnh'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(widget.author == null ? 'Thêm mới' : 'Cập nhật'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
