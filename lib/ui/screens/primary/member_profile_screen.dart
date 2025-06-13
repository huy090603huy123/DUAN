import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/members_provider.dart';
import '../../../providers/genres_provider.dart';

// Giả sử các file này tồn tại và không có lỗi
import '../../../utils/helper.dart';
import '../../../models/genre.dart'; // Giả sử model Genre được import từ đây
import '../../widgets/members/member_actions.dart';
import '../../widgets/common/genre_chips.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final membersProvider = Provider.of<MembersProvider>(context);
    final genreProvider = Provider.of<GenresProvider>(context, listen: false);
    final currMember = membersProvider.currentMember;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: currMember == null
              ? const CircularProgressIndicator()
              : FutureBuilder<List<Genre>>( // Xác định kiểu dữ liệu cho FutureBuilder
            future: genreProvider.getMemberGenres(currMember.id),
            builder: (ctx, snapshot) {
              // Thêm các trạng thái chờ và lỗi để xử lý tốt hơn
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return const Text('Something went wrong!', style: TextStyle(color: Colors.white));
              }
              // SỬA LỖI: Kiểm tra snapshot.hasData và snapshot.data không phải là null
              if (snapshot.hasData && snapshot.data != null) {
                final memberGenres = snapshot.data!;
                // Gọi setMemberPreferences trong một post-frame callback để tránh lỗi build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (membersProvider.currentMember != null) {
                    membersProvider.setMemberPreferences(memberGenres);
                  }
                });

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      //DP
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: currMember.hasImage
                            ? CircleAvatar(
                          radius: 55,
                          backgroundImage: NetworkImage(currMember.imageUrl!),
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

                      //Name
                      Text(
                        "${currMember.firstName} ${currMember.lastName}",
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      //Member details
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: Helper.hPadding),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            //Email
                            Text(
                              currMember.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 12),

                            //Age
                            Text(
                              "${currMember.age} yrs old",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 12),

                            //Membership date
                            // SỬA LỖI: Xử lý giá trị String? từ datePresenter
                            Text(
                              "Membership date: ${Helper.datePresenter(currMember.startDate) ?? 'N/A'}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 12),

                            //Member bio
                            Text(
                              currMember.bio,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 15),

                            // SỬA LỖI: Truyền danh sách không thể null
                            GenreChips(
                              color: Theme.of(context).primaryColor,
                              genres: memberGenres,
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      //Member Actions
                       MemberActions(),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }
              // Fallback trong trường hợp không có dữ liệu
              return const Text('No preferences found.', style: TextStyle(color: Colors.white));
            },
          ),
        ),
      ),
    );
  }
}