import 'package:flutter/foundation.dart';

import 'book_review.dart';
import 'author.dart';
import 'book.dart';
import 'genre.dart';

class BookDetails{

  final List<Genre> _genres;
  final List<Author> _authors;
  final List<BookReview> _reviews;
  final Book _book;

  const BookDetails({
    required List<Genre> genres,
    required List<Author> authors,
    required List<BookReview> reviews,
    required Book book,
  })  : _genres = genres,
        _authors = authors,
        _reviews = reviews,
        _book = book;

  Book get book => _book;
  List<BookReview> get reviews => _reviews;
  List<Author> get authors => _authors;
  List<Genre> get genres => _genres;

  @override
  String toString() {
    return 'BookDetails{genres: $_genres, authors: $_authors, reviews: $_reviews, book: $_book}';
  }
}