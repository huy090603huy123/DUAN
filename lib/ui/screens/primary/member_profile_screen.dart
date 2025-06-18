import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/member.dart';
import '../../../providers/members_provider.dart';
import '../../../providers/genres_provider.dart';
import '../../../models/genre.dart';
import '../../../utils/helper.dart';
import '../../widgets/members/member_actions.dart';
import '../../widgets/common/genre_chips.dart';

// --- THÊM CÁC IMPORT CHO CÁC TRANG MỚI ---
import '../issues/loan_list_screen.dart';
import '../issues/return_history_screen.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe MembersProvider để nhận biết khi profile được tải
    final membersProvider = Provider.of<MembersProvider>(context);

    // Lấy thông tin member từ provider
    final member = membersProvider.member;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          // Nếu chưa có thông tin member (đang tải hoặc chưa đăng nhập), hiển thị vòng xoay
          child: member == null
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
            child: Column(
              children: [
                // Avatar
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: (member.imageUrl != null &&
                      member.imageUrl!.isNotEmpty)
                      ? CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(member.imageUrl!),
                  )
                      : CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 65,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Tên
                Text(
                  member.memberName,
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Khung thông tin chi tiết
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                  EdgeInsets.symmetric(horizontal: Helper.hPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        member.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${member.age} yrs old",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Membership date: ${Helper.datePresenter(member.startDate) ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        member.bio ?? 'No bio available.',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Consumer<GenresProvider>(
                        builder: (context, genresProvider, child) {
                          final allGenres = genresProvider.genres;

                          if (allGenres.isEmpty) {
                            return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2));
                          }

                          final memberGenres = allGenres
                              .where((genre) => member.preferredGenreIds
                              .contains(genre.id))
                              .toList();

                          if (memberGenres.isEmpty) {
                            return const Padding(
                              padding:
                              EdgeInsets.symmetric(vertical: 8.0),
                              child: Text("No preferred genres set."),
                            );
                          }

                          return GenreChips(
                            color: Theme.of(context).primaryColor,
                            genres: memberGenres,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // --- PHẦN CODE MỚI ĐƯỢC THÊM VÀO ---
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.book_online_outlined, color: Theme.of(context).primaryColor),
                          title: const Text("Sách đang mượn"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const LoanListScreen(),
                            ));
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.history, color: Theme.of(context).primaryColor),
                          title: const Text("Lịch sử trả sách"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const ReturnHistoryScreen(),
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // --- KẾT THÚC PHẦN CODE MỚI ---

                const SizedBox(height: 20),
                const MemberActions(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}