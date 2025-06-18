import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/data_seeder.dart';
import 'firebase_options.dart';
import 'services/repositories/data_repository.dart';
import 'providers/bottom_nav_bar_provider.dart';
import 'providers/genres_provider.dart';
import 'providers/publishes_provider.dart';
import 'providers/members_provider.dart';
import 'providers/issues_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'utils/enums/status_enum.dart';
import 'ui/screens/admin/admin_home_screen.dart';
import 'utils/enums/page_type_enum.dart';
import 'ui/screens/primary/book_collections_screen.dart';
import 'ui/screens/primary/genre_books_screen.dart';
import 'ui/screens/primary/authors_gallery_screen.dart';
import 'ui/screens/primary/member_bookshelf_screen.dart';
import 'ui/screens/primary/member_profile_screen.dart';
import 'ui/screens/secondary/book_details_screen.dart';
import 'ui/screens/secondary/author_details_screen.dart';
import 'ui/screens/member_genres_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('vi_VN', null);
  await DataSeeder().seedDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MembersProvider(dataRepository: DataRepository.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => BottomNavBarProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GenresProvider(dataRepository: DataRepository.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => PublishesProvider(dataRepository: DataRepository.instance),
        ),
        ChangeNotifierProxyProvider<MembersProvider, IssuesProvider>(
          create: (context) => IssuesProvider(
            dataRepository: DataRepository.instance,
            userId: '',
          ),
          update: (context, membersProvider, previousIssuesProvider) {
            final userId = membersProvider.member?.id ?? '';
            if (previousIssuesProvider?.userId != userId) {
              return IssuesProvider(
                dataRepository: DataRepository.instance,
                userId: userId,
              );
            }
            return previousIssuesProvider!;
          },
        ),
      ],
      child: const InitialApp(),
    );
  }
}

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Deep green at top
              Color(0xFFF1F8E9), // Light green at bottom
            ],
          ),
        ),
        child: body,
      ),
    );
  }
}

class InitialApp extends StatelessWidget {
  const InitialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MembersProvider>(
      builder: (_, auth, __) {
        final themeData = _buildThemeData(context);

        final uniqueKey = ValueKey(auth.member?.id ?? 'loggedOut');

        return MaterialApp(
          key: uniqueKey,
          debugShowCheckedModeBanner: false,
          title: 'Library App',
          theme: themeData,
          home: _getHomeScreen(auth),
          routes: {
            '/admin': (context) => const GradientScaffold(body: AdminHomeScreen()),
            PageType.HOME.name: (_) => GradientScaffold(body: HomeScreen()),
            PageType.LOGIN.name: (_) => const GradientScaffold(body: LoginScreen()),
            PageType.COLLECTIONS.name: (_) => const GradientScaffold(body: BookCollectionsScreen()),
            PageType.GENRES.name: (_) => GradientScaffold(body: GenreBooksScreen()),
            PageType.AUTHORGALLERY.name: (_) => GradientScaffold(body: AuthorsGalleryScreen()),
            PageType.BOOKSHELF.name: (_) => const GradientScaffold(body: MemberBookshelfScreen()),
            PageType.PROFILE.name: (_) => const GradientScaffold(body: MemberProfileScreen()),
            PageType.BOOK.name: (_) => const GradientScaffold(body: BookDetailsScreen()),
            PageType.AUTHOR.name: (_) => const GradientScaffold(body: AuthorDetailsScreen()),
            PageType.MEMBERPREFS.name: (_) => const GradientScaffold(body: MemberGenresScreen()),
          },
        );
      },
    );
  }

  Widget _getHomeScreen(MembersProvider auth) {
    if (auth.status == Status.LOADING || auth.status == Status.INITIAL) {
      return const GradientScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isLoggedIn) {
      if (auth.isAdmin) {
        return const GradientScaffold(body: AdminHomeScreen());
      } else {
        return GradientScaffold(body: HomeScreen());
      }
    }
    return const GradientScaffold(body: LoginScreen());
  }

  ThemeData _buildThemeData(BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: Colors.green[900], // Dark green for primary elements
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
            color: Colors.green[900], // Match title color to primary
          ),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: Colors.transparent, // Transparent to allow gradient
      fontFamily: GoogleFonts.openSans().fontFamily,
      iconTheme: IconThemeData(color: Colors.grey[800]),
    );
  }
}