import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/models/genre.dart';
import 'package:warehouse/models/member_book_issue.dart';
import 'package:warehouse/services/repositories/data_repository.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để định dạng ngày tháng

// Enum cho các khoảng thời gian của biểu đồ
enum ChartTimeRange { daily, weekly, monthly }

// Lớp để chứa một điểm dữ liệu trên biểu đồ thời gian
class TimeDataPoint {
  final String label;
  final int value;
  TimeDataPoint({required this.label, required this.value});
}

// Lớp để chứa thông tin một cuốn sách được mượn nhiều
class TopBorrowedBook {
  final String bookId;
  final String bookName;
  final int borrowCount;
  TopBorrowedBook({required this.bookId, required this.bookName, required this.borrowCount});
}

// Lớp để chứa thông tin thống kê của một loại thiết bị (genre)
class GenreStat {
  final String genreId;
  final String genreName;
  final int count;
  final Color color;
  GenreStat({required this.genreId, required this.genreName, required this.count, required this.color});
}

// Lớp để chứa tất cả các giá trị thống kê
class Statistics {
  final int totalInventory;
  final int currentlyBorrowed;
  final int returnedToday;
  final int overdue;
  final List<TopBorrowedBook> topBorrowedBooks;
  final List<GenreStat> borrowedByGenre;
  final List<TimeDataPoint> borrowTrend; // Thêm dữ liệu cho biểu đồ đường

  Statistics({
    this.totalInventory = 0,
    this.currentlyBorrowed = 0,
    this.returnedToday = 0,
    this.overdue = 0,
    this.topBorrowedBooks = const [],
    this.borrowedByGenre = const [],
    this.borrowTrend = const [], // Khởi tạo giá trị
  });
}

class StatisticsProvider with ChangeNotifier {
  final DataRepository _dataRepository;
  Statistics _stats = Statistics();
  ChartTimeRange _currentTimeRange = ChartTimeRange.weekly; // Mặc định là tuần

  late StreamSubscription _booksSubscription;
  late StreamSubscription _issuesSubscription;
  late StreamSubscription _genresSubscription;

  List<Book>? _lastBooks;
  List<MemberBookIssue>? _lastIssues;
  List<Genre>? _lastGenres;

  StatisticsProvider({required DataRepository dataRepository})
      : _dataRepository = dataRepository {
    final booksStream = _dataRepository.booksStream();
    final issuesStream = _dataRepository.allBookIssuesStream();
    final genresStream = _dataRepository.genresStream();

    _booksSubscription = booksStream.listen((books) {
      _lastBooks = books;
      _tryCalculateStatistics();
    });

    _issuesSubscription = issuesStream.listen((issues) {
      _lastIssues = issues;
      _tryCalculateStatistics();
    });

    _genresSubscription = genresStream.listen((genres) {
      _lastGenres = genres;
      _tryCalculateStatistics();
    });
  }

  Statistics get stats => _stats;
  ChartTimeRange get currentTimeRange => _currentTimeRange;

  // Phương thức để thay đổi khoảng thời gian và tính toán lại
  void setTimeRange(ChartTimeRange newRange) {
    if (_currentTimeRange != newRange) {
      _currentTimeRange = newRange;
      _tryCalculateStatistics(); // Tính toán lại với khoảng thời gian mới
    }
  }

  void _tryCalculateStatistics() {
    if (_lastBooks != null && _lastIssues != null && _lastGenres != null) {
      _calculateStatistics(_lastBooks!, _lastIssues!, _lastGenres!);
    }
  }

  void _calculateStatistics(List<Book> books, List<MemberBookIssue> issues, List<Genre> genres) {
    // --- Các logic tính toán cũ ---
    final totalInventory = books.fold<int>(0, (sum, book) => sum + book.quantity);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentlyBorrowed = issues.where((issue) => issue.returnDate == null).length;
    final returnedToday = issues.where((issue) { if (issue.returnDate == null) return false; final returnDay = DateTime(issue.returnDate!.year, issue.returnDate!.month, issue.returnDate!.day); return returnDay.isAtSameMomentAs(today); }).length;
    final overdue = issues.where((issue) => issue.returnDate == null && issue.dueDate != null && issue.dueDate!.isBefore(now)).length;
    final borrowCounts = <String, int>{};
    for (final issue in issues) { if (issue.bookId != null) { borrowCounts.update(issue.bookId!, (value) => value + 1, ifAbsent: () => 1); } }
    final sortedEntries = borrowCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5Entries = sortedEntries.take(5);
    final List<TopBorrowedBook> topBorrowedBooks = [];
    for (final entry in top5Entries) { final bookId = entry.key; final book = books.firstWhere((b) => b.id == bookId, orElse: () => Book(id: bookId, name: 'Sách đã xóa', rating: 0, bio: '', imageUrl: '')); topBorrowedBooks.add(TopBorrowedBook( bookId: book.id, bookName: book.name, borrowCount: entry.value, )); }
    final genreBorrowCounts = <String, int>{};
    final issuesCurrentlyBorrowed = issues.where((issue) => issue.returnDate == null);
    for (final issue in issuesCurrentlyBorrowed) { final book = books.firstWhere((b) => b.id == issue.bookId, orElse: () => Book(id: '', name: '', rating: 0, bio: '', imageUrl: '', genreIds: [])); for (final genreId in book.genreIds) { genreBorrowCounts.update(genreId, (value) => value + 1, ifAbsent: () => 1); } }
    final random = Random();
    final availableColors = List.generate( genreBorrowCounts.length, (index) => Color.fromARGB( 255, random.nextInt(200) + 55, random.nextInt(200) + 55, random.nextInt(200) + 55, ), );
    int colorIndex = 0;
    final List<GenreStat> borrowedByGenre = [];
    genreBorrowCounts.forEach((genreId, count) { final genre = genres.firstWhere((g) => g.id == genreId, orElse: () => Genre(id: genreId, name: 'Không xác định')); borrowedByGenre.add(GenreStat( genreId: genre.id, genreName: genre.name, count: count, color: availableColors[colorIndex % availableColors.length], )); colorIndex++; });

    // --- THÊM MỚI: Logic tính toán cho biểu đồ đường ---
    final List<TimeDataPoint> borrowTrend = _calculateBorrowTrend(issues);

    _stats = Statistics(
      totalInventory: totalInventory,
      currentlyBorrowed: currentlyBorrowed,
      returnedToday: returnedToday,
      overdue: overdue,
      topBorrowedBooks: topBorrowedBooks,
      borrowedByGenre: borrowedByGenre,
      borrowTrend: borrowTrend, // Thêm dữ liệu mới
    );
    notifyListeners();
  }

  List<TimeDataPoint> _calculateBorrowTrend(List<MemberBookIssue> issues) {
    final now = DateTime.now();
    Map<String, int> counts = {};

    switch (_currentTimeRange) {
      case ChartTimeRange.daily:
      // Thống kê 7 ngày gần nhất
        for (int i = 6; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          // Sử dụng dd/MM để rõ ràng hơn
          final key = DateFormat('dd/MM').format(day);
          counts[key] = 0;
        }
        for (final issue in issues) {
          if (issue.issueDate != null && issue.issueDate!.isAfter(now.subtract(const Duration(days: 7)))) {
            final key = DateFormat('dd/MM').format(issue.issueDate!);
            counts.update(key, (value) => value + 1, ifAbsent: () => 1);
          }
        }
        break;

      case ChartTimeRange.weekly:
      // Thống kê 4 tuần gần nhất
        counts = { 'Tuần 1': 0, 'Tuần 2': 0, 'Tuần 3': 0, 'Tuần 4': 0, };
        for (final issue in issues) {
          if (issue.issueDate != null && issue.issueDate!.isAfter(now.subtract(const Duration(days: 28)))) {
            final difference = now.difference(issue.issueDate!).inDays;
            if(difference < 7) counts.update('Tuần 4', (value) => value + 1);
            else if(difference < 14) counts.update('Tuần 3', (value) => value + 1);
            else if(difference < 21) counts.update('Tuần 2', (value) => value + 1);
            else if(difference < 28) counts.update('Tuần 1', (value) => value + 1);
          }
        }
        break;

      case ChartTimeRange.monthly:
      // Thống kê 6 tháng gần nhất
        for (int i = 5; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          final key = 'T${DateFormat('M').format(month)}';
          counts[key] = 0;
        }
        for (final issue in issues) {
          if (issue.issueDate != null && issue.issueDate!.isAfter(DateTime(now.year, now.month - 5, 1))) {
            final key = 'T${DateFormat('M').format(issue.issueDate!)}';
            counts.update(key, (value) => value + 1, ifAbsent: () => 1);
          }
        }
        break;
    }

    return counts.entries.map((e) => TimeDataPoint(label: e.key, value: e.value)).toList();
  }

  @override
  void dispose() {
    _booksSubscription.cancel();
    _issuesSubscription.cancel();
    _genresSubscription.cancel();
    super.dispose();
  }
}
