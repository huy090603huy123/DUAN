import 'package:cloud_firestore/cloud_firestore.dart';



class DataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    print("Bắt đầu thêm dữ liệu mẫu...");

    // Kiểm tra xem dữ liệu đã tồn tại chưa để tránh thêm lại
    final booksSnapshot = await _firestore.collection('books').limit(1).get();
    if (booksSnapshot.docs.isNotEmpty) {
      print("Dữ liệu đã tồn tại. Bỏ qua việc thêm dữ liệu mẫu.");
      return;
    }

    // Sử dụng WriteBatch để thực hiện nhiều thao tác ghi cùng lúc
    final WriteBatch batch = _firestore.batch();

    // --- Thêm Thể loại (Genres) ---
    final genreRef1 = _firestore.collection('genres').doc();
    batch.set(genreRef1, {'name': 'Router'});

    final genreRef2 = _firestore.collection('genres').doc();
    batch.set(genreRef2, {'name': 'Switch'});

    final genreRef3 = _firestore.collection('genres').doc();
    batch.set(genreRef3, {'name': 'Firewall'});


    // --- Thêm Tác giả (Authors) ---
    final authorRef1 = _firestore.collection('authors').doc();
    batch.set(authorRef1, {
      'firstName': 'Cisco',
      'lastName': 'Herbert',
      'age': 65,
      'country': 'USA',
      'rating': 5,
      'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Cisco_logo_blue_2016.svg/1200px-Cisco_logo_blue_2016.svg.png',
    });

    final authorRef2 = _firestore.collection('authors').doc();
    batch.set(authorRef2, {
      'firstName': 'George',
      'lastName': 'Orwell',
      'age': 46,
      'country': 'UK',
      'rating': 5,
      'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/7/7e/George_Orwell_press_photo.jpg',
    });

    final authorRef3 = _firestore.collection('authors').doc();
    batch.set(authorRef3, {
      'firstName': 'Agatha',
      'lastName': 'Christie',
      'age': 85,
      'country': 'UK',
      'rating': 5,
      'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/c/cf/Agatha_Christie.png',
    });


    // --- Thêm Sách (Books) ---
    final bookRef1 = _firestore.collection('books').doc();
    batch.set(bookRef1, {
      'name': 'Cisco Catalyst 9300',
      'bio': 'Switch lớp enterprise mạnh mẽ dành cho doanh nghiệp lớn, hỗ trợ xếp chồng và bảo mật nâng cao.',
      'rating': 5,
      'publishedDate': Timestamp.fromDate(DateTime(1965, 8, 1)),
      'imageUrl': 'https://www.cisco.com/c/dam/en/us/products/collateral/switches/catalyst-9300-series-switches/catalyst-9300-48-port-data-only-stackable-switches.jpg',
      'authorIds': [authorRef1.id],
      'genreIds': [genreRef1.id],
      'quantity': 10, // <-- Bổ sung
    });

    final bookRef2 = _firestore.collection('books').doc();
    batch.set(bookRef2, {
      'name': '1984',
      'bio': 'Một cái nhìn đáng sợ về một xã hội toàn trị trong tương lai.',
      'rating': 5,
      'publishedDate': Timestamp.fromDate(DateTime(1949, 6, 8)),
      'imageUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1348990566l/5470.jpg',
      'authorIds': [authorRef2.id],
      'genreIds': [genreRef1.id, genreRef2.id],
      'quantity': 15, // <-- Bổ sung
    });

    final bookRef3 = _firestore.collection('books').doc();
    batch.set(bookRef3, {
      'name': 'Án mạng trên sông Nile',
      'bio': 'Thám tử Hercule Poirot phải tìm ra kẻ giết người trên một chuyến du thuyền sang trọng.',
      'rating': 4,
      'publishedDate': Timestamp.fromDate(DateTime(1937, 11, 1)),
      'imageUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1388212151l/131359.jpg',
      'authorIds': [authorRef3.id],
      'genreIds': [genreRef3.id],
      'quantity': 20, // <-- Bổ sung
    });

    // Thực thi tất cả các lệnh ghi
    await batch.commit();

    print("Đã thêm dữ liệu mẫu thành công!");
  }
}