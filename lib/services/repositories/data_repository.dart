import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warehouse/models/author.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/models/book_details.dart';
import 'package:warehouse/models/book_review.dart';
import 'package:warehouse/models/genre.dart';
import 'package:warehouse/models/member.dart'; // Đổi tên thành User hoặc giữ nguyên nếu muốn
import 'package:warehouse/models/member_book_issue.dart';

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

  Stream<List<Genre>> genresStream() {
    return _firestore.collection('genres').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Genre.fromFirestore(doc)).toList();
    });
  }

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

  Stream<List<Author>> authorsStream() {
    return _firestore.collection('authors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Author.fromFirestore(doc)).toList();
    });
  }

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

  // Mượn một cuốn sách
  Future<void> issueBook(Map<String, dynamic> data) {
    // data nên chứa: bookId, userId, issueDate, dueDate, status ('ISSUED')
    return _firestore.collection('book_issues').add(data);
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






// (Tương tự, bạn có thể tạo các phương thức cho author_reviews)
}