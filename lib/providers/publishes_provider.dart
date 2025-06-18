// lib/providers/publishes_provider.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/author.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/services/repositories/data_repository.dart';

class PublishesProvider with ChangeNotifier {
  final DataRepository _dataRepository;

  PublishesProvider({required DataRepository dataRepository})
      : _dataRepository = dataRepository;

  // Cung cấp stream sách, không cần thay đổi
  Stream<List<Book>> get booksStream => _dataRepository.booksStream();

  // Cung cấp stream tác giả, không cần thay đổi
  Stream<List<Author>> get authorsStream => _dataRepository.authorsStream();

  Stream<List<Book>> getBooksByGenreId(String genreId) {
    return _dataRepository.getBooksByGenreId(genreId);
  }
  Stream<List<Book>> getTop5NewBooks() {
    return _dataRepository.getTop5NewBooks();
  }

  Stream<List<Book>> getTop5RatedBooks() {
    return _dataRepository.getTop5RatedBooks();
  }

  Future<void> addBook(Map<String, dynamic> data) async {
    try {
      await _dataRepository.addBook(data);
      notifyListeners(); // Thông báo để các widget cập nhật nếu cần
    } catch (e) {
      print("Lỗi khi thêm sách: $e");
      rethrow; // Ném lại lỗi để UI có thể xử lý
    }
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      await _dataRepository.updateBook(bookId, data);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi cập nhật sách: $e");
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _dataRepository.deleteBook(bookId);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa sách: $e");
      rethrow;
    }
  }

}
