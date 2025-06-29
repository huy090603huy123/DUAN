import 'dart:async';
import 'package:flutter/material.dart';
import 'package:warehouse/models/author.dart'; // <-- Import model Author của bạn
import 'package:warehouse/services/repositories/data_repository.dart';

class AuthorsProvider with ChangeNotifier {
  final DataRepository _dataRepository;
  late StreamSubscription<List<Author>> _authorsSubscription;
  List<Author> _authors = [];

  AuthorsProvider(this._dataRepository) {
    // Ngay khi provider được tạo, bắt đầu lắng nghe sự thay đổi từ Firestore
    _authorsSubscription = _dataRepository.authorsStream().listen((authorsList) {
      _authors = authorsList;
      // Sắp xếp danh sách tác giả theo tên để hiển thị dễ dàng hơn (tùy chọn)
      _authors.sort((a, b) => a.authorName.compareTo(b.authorName));
      notifyListeners(); // Thông báo cho UI rằng dữ liệu đã thay đổi
    });
  }

  // Getter để các widget khác có thể lấy danh sách tác giả một cách an toàn
  List<Author> get authors => [..._authors];

  // Hàm tìm một tác giả cụ thể bằng ID
  Author? findById(String id) {
    try {
      return _authors.firstWhere((author) => author.id == id);
    } catch (e) {
      return null; // Trả về null nếu không tìm thấy
    }
  }

  // Hàm để thêm tác giả mới
  Future<void> addAuthor(Map<String, dynamic> data) async {
    try {
      await _dataRepository.addAuthor(data);
      // Không cần notifyListeners() ở đây, vì stream sẽ tự động làm điều đó
    } catch (error) {
      print('Lỗi khi thêm tác giả: $error');
      rethrow; // Ném lại lỗi để UI có thể hiển thị thông báo
    }
  }

  // Hàm để cập nhật thông tin tác giả
  Future<void> updateAuthor(String authorId, Map<String, dynamic> data) async {
    try {
      await _dataRepository.updateAuthor(authorId, data);
    } catch (error) {
      print('Lỗi khi cập nhật tác giả: $error');
      rethrow;
    }
  }

  // Hàm để xóa tác giả
  Future<void> deleteAuthor(String authorId) async {
    try {
      await _dataRepository.deleteAuthor(authorId);
    } catch (error) {
      print('Lỗi khi xóa tác giả: $error');
      rethrow;
    }
  }

  // Rất quan trọng: Hủy lắng nghe stream khi provider không còn được sử dụng
  // để tránh rò rỉ bộ nhớ (memory leak)
  @override
  void dispose() {
    _authorsSubscription.cancel();
    super.dispose();
  }
}