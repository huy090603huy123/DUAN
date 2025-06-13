// Import các kiểu dữ liệu model cần thiết
import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/genre.dart';
import '../../models/member.dart';
import '../../models/author_review.dart';
import '../../models/book_review.dart';
import '../../models/member_author_review.dart';
import '../../models/member_book_review.dart';
import '../../models/book_copy.dart';
import '../../models/member_book_issue.dart';

abstract class IDataRepository {
  Stream<List<Book>> booksStream();
  Stream<List<Author>> authorsStream();
  Stream<List<Genre>> genresStream();
  Stream<List<Member>> membersStream();

  Stream<Author> authorStream({required int id});
  Stream<Book> bookStream({required int id});
  Stream<Member> memberStream({required int id});

  Stream<List<int>> genreAuthorsStream({required int id});
  Stream<List<int>> genreBooksStream({required int id});
  Stream<List<int>> genreMembersStream({required int id});

  Stream<List<int>> authorGenresStream({required int id});
  Stream<List<int>> bookGenresStream({required int id});
  Stream<List<int>> memberGenresStream({required int id});

  Stream<List<AuthorReview>> authorReviewsStream({required int id});
  Stream<List<BookReview>> bookReviewsStream({required int id});
  Stream<List<MemberBookReview>> memberBookReviewsStream({required int id});
  Stream<List<MemberAuthorReview>> memberAuthorReviewsStream({required int id});

  Stream<List<int>> bookAuthorsStream({required int id});
  Stream<List<int>> authorBooksStream({required int id});

  Stream<List<int>> top5RatedBooksStream();
  Stream<List<int>> top5NewBooksStream();

  Stream<List<MemberBookIssue>> bookMemberIssuesStream({required int id});
  Stream<List<MemberBookIssue>> memberBookIssuesStream({required int id});
  Stream<List<BookCopy>> bookCopiesStream({required int id});

  Future<int> copyIssuesCount({required int id});
  Future<int> addBookIssue({required Map<String, dynamic> data});
  Future<int> createAccount({required Map<String, dynamic> data});
  Future<int> changeAccountData({required Map<String, dynamic> data, required int id});
  Future<int> changeMemberPreferences({required Map<String, dynamic> data});
  Future<void> deleteMemberPreferences({required String id});
}