import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:warehouse/models/member.dart';
import 'package:warehouse/models/book.dart';
import 'package:warehouse/providers/members_provider.dart';
import 'package:warehouse/providers/publishes_provider.dart';
import 'package:warehouse/providers/bottom_nav_bar_provider.dart'; // Đảm bảo import này nếu dùng
import 'package:warehouse/ui/widgets/collections/book_collections_sheet.dart';
import 'package:warehouse/ui/widgets/books/books_list.dart'; // Đảm bảo import này nếu dùng
import 'package:warehouse/utils/helper.dart';

class BookCollectionsScreen extends StatefulWidget {
  static const routeName = '/book-collections';

  const BookCollectionsScreen({Key? key}) : super(key: key);

  @override
  State<BookCollectionsScreen> createState() => _BookCollectionsScreenState();
}

class _BookCollectionsScreenState extends State<BookCollectionsScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  bool isSearchActive = false;

  // THÊM MỚI: Biến để đếm số thông báo sách mới được duyệt
  int _newlyApprovedCount = 0;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      final isNotEmpty = _textEditingController.text.isNotEmpty;
      if (isSearchActive != isNotEmpty) {
        setState(() {
          isSearchActive = isNotEmpty;
        });
      }
    });

    // DEMO: Tạm gán số thông báo để hiển thị badge
    // Trong thực tế, bạn sẽ lắng nghe một stream từ provider
    // để lấy số lượng sách mới được duyệt cho người dùng này.
    _newlyApprovedCount = 3; // Ví dụ có 3 thông báo mới
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // THÊM MỚI: Hàm hiển thị danh sách sách đã được duyệt
  void _showApprovedBooks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép bottom sheet có thể cuộn và mở rộng
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, // Bắt đầu với 70% chiều cao màn hình
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Consumer<PublishesProvider>(
              builder: (consumerContext, pubProv, child) {
                return StreamBuilder<List<Book>>(
                  stream: pubProv.booksStream, // Lấy tất cả sách
                  builder: (streamContext, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Đã có lỗi: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có sách nào.'));
                    }

                    // QUAN TRỌNG: TRONG ỨNG DỤNG THỰC TẾ, BẠN SẼ LỌC DANH SÁCH NÀY
                    // DỰA TRÊN TRẠNG THÁI 'ĐÃ DUYỆT' CỦA SÁCH (ví dụ: book.isApproved == true)
                    // VÀ CÓ THỂ LỌC THÊM CẢ NHỮNG SÁCH MÀ NGƯỜI DÙNG CHƯA XEM.
                    final approvedBooks = snapshot.data!; // DEMO: Tạm thời hiển thị tất cả sách

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sách đã được duyệt',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              // Nút "Đánh dấu đã đọc"
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _newlyApprovedCount = 0; // Reset số thông báo
                                  });
                                  Navigator.of(context).pop(); // Đóng bottom sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã đánh dấu tất cả sách đã duyệt là đã đọc')),
                                  );
                                },
                                child: const Text('Đánh dấu đã đọc'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: approvedBooks.length,
                            itemBuilder: (listCtx, index) {
                              final book = approvedBooks[index];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                                      ? Image.network(
                                    book.imageUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
                                  )
                                      : Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book, color: Colors.grey),
                                  ),
                                ),
                                title: Text(book.name),
                                subtitle: Text('Số lượng: ${book.quantity}'),
                                // Bạn có thể thêm onTap để xem chi tiết sách
                                onTap: () {
                                  // Ví dụ: Điều hướng đến trang chi tiết sách
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (ctx) => BookDetailsScreen(bookId: book.id),
                                  //   ),
                                  // );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final Member? member = Provider.of<MembersProvider>(context).member;
    const headerColor = Color(0xFF2E593F);
    const backgroundColor = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: headerColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- Phần Header (Không cuộn) ---
            _buildHeader(context, member),
            const SizedBox(height: 20),
            // --- Phần Thanh tìm kiếm và nút chức năng (Không cuộn) ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        isSearchActive = val.isNotEmpty;
                      });
                    },
                    controller: _textEditingController,
                    cursorColor: Theme.of(context).primaryColor,
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(17),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Bạn muốn tìm sản phẩm gì?",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatButton(Icons.devices_other, "Thiết Bị", ""),
                          _buildStatButton(Icons.phone_in_talk, "Liên hệ", ""),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // --- Phần nội dung chính (Có thể cuộn) ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: isSearchActive
                    ? BookSearchSheet(searchTerm: _textEditingController.text.trim())
                    : const BookCollectionsSheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Member? member) {
    // Xác định văn bản vai trò dựa trên dữ liệu thành viên
    String roleText;
    if (member?.role == 'admin') {
      roleText = 'Quản trị viên';
    } else if (member?.role == 'user') {
      roleText = 'Nhân viên';
    } else {
      roleText = 'Khách'; // Giá trị mặc định
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            // onTap: () => Provider.of<BottomNavigationBarProvider>(context, listen: false).currentIndex = 3,
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 26,
                backgroundImage: (member?.imageUrl != null && member!.imageUrl!.isNotEmpty)
                    ? NetworkImage(member.imageUrl!)
                    : null,
                child: (member?.imageUrl == null || member!.imageUrl!.isEmpty)
                    ? Text(member?.memberInitials ?? '?', style: const TextStyle(fontSize: 20, color: Colors.black87))
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              //    onTap: () => Provider.of<BottomNavigationBarProvider>(context, listen: false).currentIndex = 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member?.memberName ?? 'Loading...',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Hiển thị vai trò đã được xác định
                  Text(
                    roleText,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // CẬP NHẬT: Thêm biểu tượng thông báo với badge
          IconButton(
            onPressed: () {
              _showApprovedBooks(context); // Gọi hàm hiển thị sách đã duyệt
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                if (_newlyApprovedCount > 0) // Chỉ hiển thị badge nếu có thông báo mới
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_newlyApprovedCount', // Hiển thị số thông báo
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.green[700], size: 28),
          onPressed: () {},
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[800], fontSize: 13),
        ),
      ],
    );
  }
}

class BookSearchSheet extends StatelessWidget {
  final String searchTerm;

  const BookSearchSheet({
    super.key,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(Helper.hPadding, 20, Helper.hPadding, 10),
          child: Text(
            "Kết quả tìm kiếm",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        Expanded(
          child: Consumer<PublishesProvider>(
            builder: (ctx, pubProv, child) {
              return StreamBuilder<List<Book>>(
                stream: pubProv.booksStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Không có sản phẩm nào."));
                  }
                  final filteredBooks = snapshot.data!
                      .where((book) => book.name.toLowerCase().contains(searchTerm.toLowerCase()))
                      .toList();

                  if (filteredBooks.isEmpty) {
                    return const Center(child: Text("Không tìm thấy sản phẩm phù hợp."));
                  }

                  return BooksList(books: filteredBooks);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}