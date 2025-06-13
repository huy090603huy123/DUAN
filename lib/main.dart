import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Giả định rằng các file này tồn tại và không có lỗi bên trong.
import 'services/repositories/data_repository.dart';
import 'providers/author_details_provider.dart';
import 'providers/book_details_provider.dart';
import 'providers/bottom_nav_bar_provider.dart';
import 'providers/genres_provider.dart';
import 'providers/publishes_provider.dart';
import 'providers/reviews_provider.dart';
import 'providers/issues_provider.dart';
import 'providers/members_provider.dart';
import 'utils/enums/page_type_enum.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp MembersProvider cho toàn bộ cây widget con.
    return ChangeNotifierProvider<MembersProvider>(
      create: (_) => MembersProvider(dataRepository: DataRepository.instance),
      child: const InitialApp(),
    );
  }
}

class InitialApp extends StatelessWidget {
  const InitialApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái đăng nhập từ MembersProvider.
    return Consumer<MembersProvider>(
      builder: (_, auth, __) {
        // Nếu người dùng chưa đăng nhập, hiển thị màn hình Login.
        if (!auth.loggedIn) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Library App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: Colors.blue[800],
              textTheme: TextTheme(
                displayLarge: GoogleFonts.literata(
                  textStyle: const TextStyle(
                    fontSize: 50,
                    letterSpacing: .5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                headlineLarge: GoogleFonts.literata(
                  textStyle: const TextStyle(
                    fontSize: 30,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                titleLarge: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              scaffoldBackgroundColor: Colors.blue[800],
              fontFamily: GoogleFonts.openSans().fontFamily,
              iconTheme: IconThemeData(color: Colors.grey[800]),
            ),
            home: PageType.LOGIN.getRoute(),
          );
        }
        // Nếu đã đăng nhập, hiển thị ứng dụng chính.
        return MainApp(membersProvider: auth);
      },
    );
  }
}

class MainApp extends StatelessWidget {
  final MembersProvider membersProvider;

  const MainApp({
    super.key,
    required this.membersProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BottomNavBarProvider>(create: (_) => BottomNavBarProvider()),
        ChangeNotifierProvider<GenresProvider>(
          create: (_) => GenresProvider(dataRepository: DataRepository.instance),
        ),
        ChangeNotifierProvider<PublishesProvider>(
            create: (_) => PublishesProvider(dataRepository: DataRepository.instance)),
        ChangeNotifierProvider<ReviewsProvider>(
          create: (_) => ReviewsProvider(dataRepository: DataRepository.instance),
        ),
        ChangeNotifierProxyProvider3<PublishesProvider, GenresProvider, ReviewsProvider,
            BookDetailsProvider>(
          create: (_) => BookDetailsProvider(
            publishesProvider: PublishesProvider(dataRepository: DataRepository.instance),
            genresProvider: GenresProvider(dataRepository: DataRepository.instance),
            reviewsProvider: ReviewsProvider(dataRepository: DataRepository.instance),
          ),
          update: (_, pProv, gProv, rProv, prevBkDetails) => BookDetailsProvider(
            publishesProvider: pProv,
            genresProvider: gProv,
            reviewsProvider: rProv,
          ),
        ),
        ChangeNotifierProxyProvider3<PublishesProvider, GenresProvider, ReviewsProvider,
            AuthorDetailsProvider>(
          create: (_) => AuthorDetailsProvider(
            publishesProvider: PublishesProvider(dataRepository: DataRepository.instance),
            genresProvider: GenresProvider(dataRepository: DataRepository.instance),
            reviewsProvider: ReviewsProvider(dataRepository: DataRepository.instance),
          ),
          update: (_, pProv, gProv, rProv, prevBkDetails) => AuthorDetailsProvider(
            publishesProvider: pProv,
            genresProvider: gProv,
            reviewsProvider: rProv,
          ),
        ),
        ChangeNotifierProvider<IssuesProvider>(
          // SỬA LỖI: Thêm dấu '!' để khẳng định currentMId không phải là null.
          // Điều này an toàn vì widget này chỉ được build khi người dùng đã đăng nhập.
          create: (_) => IssuesProvider(
              dataRepository: DataRepository.instance, currentMId: membersProvider.currentMId!),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Library App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[800],
          textTheme: TextTheme(
            displayLarge: GoogleFonts.literata(
              textStyle: const TextStyle(
                fontSize: 50,
                letterSpacing: .5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            headlineLarge: GoogleFonts.literata(
              textStyle: const TextStyle(
                fontSize: 30,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            titleLarge: GoogleFonts.openSans(
              textStyle: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.blue[800],
          fontFamily: GoogleFonts.openSans().fontFamily,
          iconTheme: IconThemeData(color: Colors.grey[800]),
        ),
        initialRoute: PageType.HOME.name,
        routes: {
          PageType.HOME.name: (_) => PageType.HOME.getRoute(),
          PageType.COLLECTIONS.name: (_) => PageType.COLLECTIONS.getRoute(),
          PageType.GENRES.name: (_) => PageType.GENRES.getRoute(),
          PageType.AUTHOR.name: (_) => PageType.AUTHOR.getRoute(),
          PageType.MEMBERPREFS.name: (_) => PageType.MEMBERPREFS.getRoute(),
          PageType.AUTHORGALLERY.name: (_) => PageType.AUTHORGALLERY.getRoute(),
          PageType.AUTHORBOOKS.name: (_) => PageType.AUTHORBOOKS.getRoute(),
          PageType.BOOK.name: (_) => PageType.BOOK.getRoute(),
          PageType.BOOKSHELF.name: (_) => PageType.BOOKSHELF.getRoute(),
          PageType.PROFILE.name: (_) => PageType.PROFILE.getRoute(),
          PageType.LOGIN.name: (_) => PageType.LOGIN.getRoute(),
        },
      ),
    );
  }
}