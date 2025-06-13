import 'dart:collection';

import 'package:flutter/material.dart';

import '../services/repositories/data_repository.dart';

import '../models/author.dart';
import '../models/book.dart';

class PublishesProvider with ChangeNotifier {
  final DataRepository _dataRepository;

  // SỬA LỖI: Thay @required bằng required và dùng cú pháp khởi tạo đúng
  PublishesProvider({required DataRepository dataRepository}) : _dataRepository = dataRepository {
    _initializeData();
  }

  final Map<int, Author> _authors = Map();
  final Map<int, Book> _books = Map();

  void _initializeData() {
    _initializeAuthorsMap();
    _initializeBooksMap();
  }

  void _initializeAuthorsMap() {
    _dataRepository.authorsStream().listen((authors) {
      for (var author in authors) {
        _authors[author.id] = author;
      }
      notifyListeners();
    });
  }

  void _initializeBooksMap() {
    _dataRepository.booksStream().listen((books) {
      for (var book in books) {
        _books[book.id] = book;
      }
      notifyListeners();
    });
  }

  UnmodifiableMapView<int, Author> get authorsMap => UnmodifiableMapView(_authors);
  UnmodifiableListView<Author> get authors => UnmodifiableListView(_authors.values);

  UnmodifiableMapView<int, Book> get booksMap => UnmodifiableMapView(_books);
  UnmodifiableListView<Book> get books => UnmodifiableListView(_books.values);

  // SỬA LỖI: Kiểu trả về phải là nullable Book?
  Book? getBook(int bkId) => _books[bkId];

  // SỬA LỖI: Kiểu trả về phải là nullable Author?
  Author? getAuthor(int aId) => _authors[aId];

  Future<List<Author>> getBookAuthors(int bkId) async {
    List<Author> bookAuthors = [];
    await for (List<int> authorIds in _dataRepository.bookAuthorsStream(id: bkId)) {
      // SỬA LỖI: Kiểm tra null trước khi thêm
      for (var aId in authorIds) {
        final author = _authors[aId];
        if (author != null) {
          bookAuthors.add(author);
        }
      }
    }
    return bookAuthors;
  }

  Future<List<Book>> getAuthorBooks(int aId) async {
    List<Book> authorBooks = [];
    await for (List<int> bookIds in _dataRepository.authorBooksStream(id: aId)) {
      // SỬA LỖI: Kiểm tra null trước khi thêm
      for (var bkId in bookIds) {
        final book = _books[bkId];
        if (book != null) {
          authorBooks.add(book);
        }
      }
    }
    return authorBooks;
  }

  Stream<List<Book>> getGenreBooks(int gId) {
    return _dataRepository.genreBooksStream(id: gId).map<List<Book>>((bookIds) {
      // SỬA LỖI: Lọc bỏ các giá trị null
      return bookIds
          .map((bkId) => _books[bkId]) // tạo ra Iterable<Book?>
          .whereType<Book>() // lọc bỏ null, chỉ giữ lại các đối tượng Book
          .toList();
    });
  }

  Stream<List<Book>> getTop5RatedBooks() {
    return _dataRepository.top5RatedBooksStream().map<List<Book>>((bookIds) {
      // SỬA LỖI: Lọc bỏ các giá trị null
      return bookIds
          .map((bkId) => _books[bkId])
          .whereType<Book>()
          .toList();
    });
  }

  Stream<List<Book>> getTop5NewBooks() {
    return _dataRepository.top5NewBooksStream().map<List<Book>>((bookIds) {
      // SỬA LỖI: Lọc bỏ các giá trị null
      return bookIds
          .map((bkId) => _books[bkId])
          .whereType<Book>()
          .toList();
    });
  }
}