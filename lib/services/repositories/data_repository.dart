import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warehouse/models/author.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/models/book_details.dart';
import 'package:warehouse/models/book_review.dart';
import 'package:warehouse/models/genre.dart';
import 'package:warehouse/models/member.dart'; // Đổi tên thành User hoặc giữ nguyên nếu muốn
import 'package:warehouse/models/member_book_issue.dart';

import '../../models/borrow_request.dart';

// Giả định rằng bạn đã cập nhật các model của mình với phương thức `fromFirestore`
// Ví dụ: Book.fromFirestore(doc), Author.fromFirestore(doc), ...

class DataRepository {
  DataRepository._();
  static final DataRepository instance = DataRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- PHƯƠNG THỨC XÁC THỰC (AUTH) ---

  // Lấy stream trạng thái đăng nhập của người dùng
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy người dùng hiện tại
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(
      {required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(
      {required String email, required String password}) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  // --- PHƯƠNG THỨC QUẢN LÝ NGƯỜI DÙNG (MEMBERS/USERS) ---

  // Tạo thông tin người dùng trong collection 'users' sau khi đăng ký
  Future<void> createUserProfile(
      {required String uid, required Map<String, dynamic> data}) {
    return _firestore.collection('users').doc(uid).set(data);
  }

  // Lấy thông tin chi tiết của một người dùng
  Future<Member?> getUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        // Giả sử model Member có fromFirestore
        return Member.fromFirestore(snapshot);
      }
      return null;
    });
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUserProfile(
      {required String uid, required Map<String, dynamic> data}) {
    return _firestore.collection('users').doc(uid).update(data);
  }

  // --- PHƯƠNG THỨC QUẢN LÝ SÁCH (BOOKS) ---

  Stream<List<Book>> booksStream() {
    return _firestore.collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  Stream<Book> bookDetailsStream(String bookId) {
    return _firestore
        .collection('books')
        .doc(bookId)
        .snapshots()
        .map((doc) => Book.fromFirestore(doc));
  }

  Future<void> setBook(Map<String, dynamic> data) {
    return _firestore.collection('books').add(data);
  }

  Future<void> editBook({required String bookId, required Map<String, dynamic> data}) {
    return _firestore.collection('books').doc(bookId).update(data);
  }



  // --- PHƯƠNG THỨC QUẢN LÝ THỂ LOẠI (GENRES) ---



  // Lấy sách thuộc về một thể loại cụ thể
  // Giả định model 'books' có một trường mảng 'genreIds'
  Stream<List<Book>> genreBooksStream(String genreId) {
    return _firestore
        .collection('books')
        .where('genreIds', arrayContains: genreId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }


  // --- PHƯƠNG THỨC QUẢN LÝ TÁC GIẢ (AUTHORS) ---

 

  Stream<Author> authorDetailsStream(String authorId) {
    return _firestore
        .collection('authors')
        .doc(authorId)
        .snapshots()
        .map((doc) => Author.fromFirestore(doc));
  }

  // --- PHƯƠNG THỨC QUẢN LÝ MƯỢN/TRẢ SÁCH (ISSUES) ---

  // Lấy danh sách sách mà một người dùng đã mượn
  Stream<List<MemberBookIssue>> memberBookIssues(String userId) {
    return _firestore
        .collection('book_issues')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MemberBookIssue.fromFirestore(doc))
        .toList());
  }

  /// **MỚI: Mượn sách và giảm số lượng tồn kho (sử dụng Transaction).**
  /// Phương thức này thay thế cho hàm `issueBook` cũ.
  Future<void> issueBookAndUpdateQuantity({
    required Map<String, dynamic> issueData,
    required String bookId,
  }) {
    final bookRef = _firestore.collection('books').doc(bookId);
    final issueRef = _firestore.collection('book_issues').doc(); // Tạo ID mới cho phiếu mượn

    // Một transaction sẽ thực hiện tất cả các thao tác đọc và ghi như một đơn vị duy nhất.
    // Nếu bất kỳ thao tác nào thất bại, toàn bộ transaction sẽ được hủy bỏ.
    return _firestore.runTransaction((transaction) async {
      // 1. Đọc thông tin sách hiện tại
      final bookSnapshot = await transaction.get(bookRef);

      if (!bookSnapshot.exists) {
        throw Exception("Sách không tồn tại!");
      }

      final bookData = bookSnapshot.data();
      final currentQuantity = bookData?['quantity'] ?? 0;

      // 2. Kiểm tra xem sách còn không
      if (currentQuantity <= 0) {
        throw Exception("Sách đã hết hàng!");
      }

      // 3. Nếu còn, giảm số lượng đi 1 và cập nhật sách
      transaction.update(bookRef, {'quantity': FieldValue.increment(-1)});

      // 4. Tạo phiếu mượn sách mới
      transaction.set(issueRef, issueData);
    });
  }


  /// **CẬP NHẬT: Trả sách, cập nhật số lượng và thêm đánh giá (sử dụng Transaction).**
  /// Phương thức này thay thế cho hàm `returnBook` cũ.
  Future<void> returnBookAndUpdateQuantity({
    required String issueId,
    required String bookId,
    required String userId,
    required int rating,
    required String review,
  }) {
    final bookRef = _firestore.collection('books').doc(bookId);
    final issueRef = _firestore.collection('book_issues').doc(issueId);

    // Sử dụng transaction để đảm bảo tất cả các cập nhật diễn ra đồng bộ
    return _firestore.runTransaction((transaction) async {
      // 1. Cập nhật số lượng sách: Tăng lên 1
      transaction.update(bookRef, {'quantity': FieldValue.increment(1)});

      // 2. Cập nhật trạng thái của phiếu mượn sách
      transaction.update(issueRef, {
        'status': 'RETURNED',
        'returnDate': Timestamp.now(),
      });

      // 3. Nếu người dùng có để lại đánh giá hoặc xếp hạng
      if (review.isNotEmpty || rating > 0) {
        // Thêm một bài đánh giá mới
        final reviewRef = _firestore.collection('book_reviews').doc();
        transaction.set(reviewRef, {
          'bookId': bookId,
          'userId': userId,
          'rating': rating,
          'review': review,
          'createdAt': Timestamp.now(),
        });

        // Cập nhật rating trung bình của sách
        // Lưu ý: Để tính toán chính xác hơn, bạn có thể cần lưu tổng số sao (totalStars)
        // và tổng số lượt đánh giá (reviewCount) riêng biệt.
        transaction.update(bookRef, {
          // 'totalRatings': FieldValue.increment(rating), // Cân nhắc thêm trường này
          'rating': rating, // Cập nhật rating tạm thời, cần logic phức tạp hơn cho rating trung bình
          'reviewCount': FieldValue.increment(1),
        });
      }
    });
  }

  Stream<List<MemberBookIssue>> allBookIssuesStream() {
    return _firestore
        .collection('book_issues')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MemberBookIssue.fromFirestore(doc))
        .toList());
  }
  // Mượn một cuốn sách
  Future<void> issueBook(Map<String, dynamic> data) {
    // data nên chứa: bookId, userId, issueDate, dueDate, status ('ISSUED')
    return _firestore.collection('book_issues').add(data);
  }

  Stream<List<Genre>> genresStream() {
    return _firestore.collection('genres').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Genre.fromFirestore(doc)).toList();
    });
  }

  Future<void> addGenre(Map<String, dynamic> data) {
    return _firestore.collection('genres').add(data);
  }

  Future<void> updateGenre(String genreId, Map<String, dynamic> data) {
    return _firestore.collection('genres').doc(genreId).update(data);
  }

  Future<void> deleteGenre(String genreId) {
    return _firestore.collection('genres').doc(genreId).delete();
  }


  Future<void> createBorrowRequest(Map<String, dynamic> requestData) {
    return _firestore.collection('borrow_requests').add(requestData);
  }

  /// Lấy stream của tất cả các yêu cầu mượn sách (dành cho admin)
  Stream<List<BorrowRequest>> getBorrowRequests() {
    return _firestore
        .collection('borrow_requests')
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BorrowRequest.fromFirestore(doc))
        .toList());
  }


  /// Phê duyệt yêu cầu mượn sách (sử dụng Transaction)
  Future<void> approveBorrowRequest({
    required String requestId,
    required String bookId,
    required Map<String, dynamic> issueData,
  }) {
    final requestRef = _firestore.collection('borrow_requests').doc(requestId);
    final bookRef = _firestore.collection('books').doc(bookId);
    final issueRef = _firestore.collection('book_issues').doc();

    return _firestore.runTransaction((transaction) async {
      final bookSnapshot = await transaction.get(bookRef);

      if (!bookSnapshot.exists) {
        throw Exception("Sách không tồn tại!");
      }

      final currentQuantity = bookSnapshot.data()?['quantity'] ?? 0;
      if (currentQuantity <= 0) {
        throw Exception("Sách đã hết hàng!");
      }

      // 1. Cập nhật trạng thái yêu cầu -> approved
      transaction.update(requestRef, {'status': 'approved'});

      // 2. Giảm số lượng sách đi 1
      transaction.update(bookRef, {'quantity': FieldValue.increment(-1)});

      // 3. Tạo một bản ghi mượn sách mới
      transaction.set(issueRef, issueData);
    });
  }

  /// Từ chối yêu cầu mượn sách
  Future<void> rejectBorrowRequest(String requestId) {
    return _firestore
        .collection('borrow_requests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  // Trả sách và để lại đánh giá (sử dụng Batched Write để đảm bảo tính toàn vẹn)
  Future<void> returnBook({
    required String issueId,
    required String bookId,
    required String userId,
    required int rating,
    required String review,
  }) async {
    final WriteBatch batch = _firestore.batch();

    // 1. Cập nhật trạng thái của lượt mượn sách
    final issueRef = _firestore.collection('book_issues').doc(issueId);
    batch.update(issueRef, {
      'status': 'RETURNED',
      'returnDate': Timestamp.now(),
    });

    // 2. Thêm một bài đánh giá mới cho sách
    final reviewRef = _firestore.collection('book_reviews').doc();
    batch.set(reviewRef, {
      'bookId': bookId,
      'userId': userId,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.now(),
    });

    if (review.isNotEmpty || rating > 0) {
      final reviewRef = _firestore.collection('book_reviews').doc();
      batch.set(reviewRef, {
        'bookId': bookId,
        'userId': userId,
        'rating': rating,
        'review': review,
        'createdAt': Timestamp.now(),
      });
    }
    // 3. Cập nhật rating trung bình của sách (sử dụng FieldValue.increment)
    final bookRef = _firestore.collection('books').doc(bookId);
    batch.update(bookRef, {
      'totalRatings': FieldValue.increment(rating),
      'reviewCount': FieldValue.increment(1),
    });
    // Lưu ý: Bạn sẽ cần tính rating trung bình trên client hoặc bằng Cloud Function.
    // Ví dụ: (totalRatings + rating) / (reviewCount + 1)

    // Thực thi tất cả các thao tác
    await batch.commit();
  }

  // --- PHƯƠNG THỨC ĐÁNH GIÁ (REVIEWS) ---

  // Lấy tất cả đánh giá của một cuốn sách
  Stream<List<BookReview>> bookReviews(String bookId) {
    return _firestore
        .collection('book_reviews')
        .where('bookId', isEqualTo: bookId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => BookReview.fromFirestore(doc)).toList());
  }
  Future<List<Author>> getAuthorsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final List<Author> authors = [];
    // Firestore chỉ cho phép truy vấn 'whereIn' với tối đa 10 phần tử
    // Chúng ta sẽ chia nhỏ danh sách ID để xử lý
    for (var i = 0; i < ids.length; i += 10) {
      final sublist = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final querySnapshot = await _firestore
          .collection('authors')
          .where(FieldPath.documentId, whereIn: sublist)
          .get();
      authors.addAll(
          querySnapshot.docs.map((doc) => Author.fromFirestore(doc)).toList());
    }
    return authors;
  }

  // Lấy nhiều thể loại dựa trên danh sách các ID
  Future<List<Genre>> getGenresByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final List<Genre> genres = [];
    for (var i = 0; i < ids.length; i += 10) {
      final sublist = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final querySnapshot = await _firestore
          .collection('genres')
          .where(FieldPath.documentId, whereIn: sublist)
          .get();
      genres.addAll(
          querySnapshot.docs.map((doc) => Genre.fromFirestore(doc)).toList());
    }
    return genres;
  }
  Stream<List<Book>> getBooksByAuthorId(String authorId) {
    return _firestore
        .collection('books')
        .where('authorIds', arrayContains: authorId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }
  Stream<List<Book>> getBooksByGenreId(String genreId) {
    return _firestore
        .collection('books')
        .where('genreIds', arrayContains: genreId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }
  Future<void> addIssue(Map<String, dynamic> data) {
    return _firestore.collection('book_issues').add(data);
  }
  Stream<List<Book>> getTop5NewBooks() {
    return _firestore
        .collection('books')
        .orderBy('publishedDate', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  /// Lấy 5 cuốn sách được đánh giá cao nhất.
  Stream<List<Book>> getTop5RatedBooks() {
    return _firestore
        .collection('books')
        .orderBy('rating', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }



  Future<void> addBook(Map<String, dynamic> data) async {
    await _firestore.collection('books').add(data);
  }

  /// Cập nhật thông tin cho một cuốn sách đã có dựa trên ID.
  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    await _firestore.collection('books').doc(bookId).update(data);
  }

  /// Xóa một cuốn sách khỏi Firestore dựa trên ID.
  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  Stream<List<Author>> authorsStream() {
    return _firestore.collection('authors').snapshots().map((snapshot) {
      // Chuyển đổi mỗi document thành một đối tượng Author
      return snapshot.docs.map((doc) => Author.fromFirestore(doc)).toList();
    });
  }

// Thêm một tác giả mới
  Future<void> addAuthor(Map<String, dynamic> data) {
    return _firestore.collection('authors').add(data);
  }

// Cập nhật thông tin một tác giả
  Future<void> updateAuthor(String authorId, Map<String, dynamic> data) {
    return _firestore.collection('authors').doc(authorId).update(data);
  }

// Xóa một tác giả
  Future<void> deleteAuthor(String authorId) {
    return _firestore.collection('authors').doc(authorId).delete();
  }




// (Tương tự, bạn có thể tạo các phương thức cho author_reviews)
}