import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/book.dart'; // Giữ nguyên để tránh lỗi nếu bạn tái sử dụng model Book

class DataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    print('Bắt đầu quá trình seeding...');

    await _seedCollection(
      collectionName: 'books',
      dataList: _getSampleBooks(),
      docIdProvider: (book) => book.id,
      toJsonConverter: (book) => book.toJson(),
    );

    print('Quá trình seeding hoàn tất.');
  }

  Future<void> _seedCollection<T>({
    required String collectionName,
    required List<T> dataList,
    required String Function(T) docIdProvider,
    required Map<String, dynamic> Function(T) toJsonConverter,
  }) async {
    final collectionRef = _firestore.collection(collectionName);
    int seededCount = 0;

    for (final item in dataList) {
      final docId = docIdProvider(item);
      final docRef = collectionRef.doc(docId);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set(toJsonConverter(item));
        seededCount++;
      }
    }

    if (seededCount > 0) {
      print('Đã ghi $seededCount mục mới vào collection "$collectionName".');
    } else {
      print('Collection "$collectionName" đã có sẵn dữ liệu, không có gì thay đổi.');
    }
  }

  static List<Book> _getSampleBooks() {
    return [
      Book(
        id: 'tp-link-router-archer-ax20',
        name: 'Router TP-Link Archer AX20',
        rating: 5,
        bio: 'Thiết bị phát Wi-Fi chuẩn Wi-Fi 6 tốc độ cao, phù hợp cho hộ gia đình và văn phòng vừa. Hỗ trợ nhiều kết nối đồng thời, ổn định và bảo mật.',
        imageUrl: 'https://m.media-amazon.com/images/I/61R7fHUNYUL._AC_SL1500_.jpg',
        publishedDate: DateTime(2023, 3, 1),
        quantity: 8,
        authorIds: ['tp-link'], // Giữ nguyên tên biến
        genreIds: ['router', 'wifi-6'],
      ),
      Book(
        id: 'cisco-switch-sg350-28',
        name: 'Switch Cisco SG350-28',
        rating: 4,
        bio: 'Thiết bị chuyển mạch Layer 3 có 28 cổng Gigabit, quản lý thông minh, phù hợp cho doanh nghiệp nhỏ và vừa.',
        imageUrl: 'https://m.media-amazon.com/images/I/81QhhXyZtzL._AC_SL1500_.jpg',
        publishedDate: DateTime(2022, 5, 10),
        quantity: 5,
        authorIds: ['cisco'],
        genreIds: ['switch', 'layer3'],
      ),
      Book(
        id: 'unifi-ap-ac-pro',
        name: 'Access Point UniFi AC Pro',
        rating: 5,
        bio: 'Thiết bị phát Wi-Fi chuyên dụng cho doanh nghiệp, hỗ trợ nhiều người dùng, quản lý tập trung bằng UniFi Controller.',
        imageUrl: 'https://m.media-amazon.com/images/I/71sQ3NnF+DL._AC_SL1500_.jpg',
        publishedDate: DateTime(2021, 11, 5),
        quantity: 12,
        authorIds: ['ubiquiti'],
        genreIds: ['access-point', 'enterprise'],
      ),
    ];
  }
}
