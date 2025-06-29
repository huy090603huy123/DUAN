import 'dart:collection';
import 'package:flutter/material.dart';
import '../models/genre.dart';
import '../services/repositories/data_repository.dart';

class GenresProvider with ChangeNotifier {
  final DataRepository _dataRepository;

  // THAY ĐỔI 1: Chuyển sang Map<String, Genre> để khớp với ID của Firestore.
  final Map<String, Genre> _genres = {};

  // Sử dụng một List để đảm bảo thứ tự và truy cập an toàn qua index.
  List<Genre> _genreList = [];

  int _activeIndex = 0;

  // Cập nhật cú pháp constructor
  GenresProvider({required DataRepository dataRepository})
      : _dataRepository = dataRepository {
    _initializeData();
  }
  Future<void> addGenre(Map<String, dynamic> data) async {
    try {
      await _dataRepository.addGenre(data);
      // notifyListeners() sẽ được gọi tự động bởi stream listener
    } catch (e) {
      print("Lỗi khi thêm thể loại: $e");
      rethrow;
    }
  }

  Future<void> updateGenre(String genreId, Map<String, dynamic> data) async {
    try {
      await _dataRepository.updateGenre(genreId, data);
    } catch (e) {
      print("Lỗi khi cập nhật thể loại: $e");
      rethrow;
    }
  }

  Future<void> deleteGenre(String genreId) async {
    try {
      await _dataRepository.deleteGenre(genreId);
    } catch (e) {
      print("Lỗi khi xóa thể loại: $e");
      rethrow;
    }
  }
  // --- GETTERS: Cung cấp dữ liệu cho UI một cách an toàn ---

  /// Trả về một danh sách các thể loại không thể bị thay đổi từ bên ngoài.
  UnmodifiableListView<Genre> get genres => UnmodifiableListView(_genreList);

  /// Lấy ID của thể loại đang được người dùng chọn.
  String? get activeGenreId {
    if (_genreList.isNotEmpty && _activeIndex < _genreList.length) {
      return _genreList[_activeIndex].id;
    }
    return null;
  }

  /// Lấy index của thể loại đang được chọn.
  int get activeIndex => _activeIndex;


  // --- METHODS: Các hàm xử lý logic ---

  /// Khởi tạo dữ liệu bằng cách lắng nghe stream từ DataRepository.
  void _initializeData() {
    _dataRepository.genresStream().listen((genresFromRepo) {
      _genres.clear();
      for (var genre in genresFromRepo) {
        _genres[genre.id] = genre; // `genre.id` bây giờ là String.
      }

      // Cập nhật lại danh sách có thứ tự từ Map.
      _genreList = _genres.values.toList();

      // Thông báo cho các widget đang lắng nghe để chúng build lại giao diện.
      notifyListeners();
    });
  }

  /// Kiểm tra xem một index có phải là index đang được chọn hay không.
  bool isActiveIndex(int i) => _activeIndex == i;

  /// Cập nhật lại index đang được chọn (ví dụ: khi người dùng nhấn vào một genre khác).
  void setActiveIndex(int newIndex) {
    if (newIndex >= 0 && newIndex < _genreList.length) {
      _activeIndex = newIndex;
      notifyListeners();
    }
  }

// THAY ĐỔI 2: Tất cả các phương thức getBookGenres, getAuthorGenres, getMemberGenres
// đã được xóa bỏ khỏi đây. Logic của chúng đã được chuyển sang các provider
// chi tiết hơn như BookDetailsProvider để đảm bảo mỗi provider có một
// trách nhiệm duy nhất.
}