import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/bottom_nav_bar_provider.dart';

import '../../../utils/enums/page_type_enum.dart';

class BottomNavBar extends StatelessWidget {
  final PageController pageController;

  // SỬA LỖI: Cập nhật cú pháp constructor
  const BottomNavBar({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<BottomNavBarProvider, PageType>(
      selector: (ctx, bottomNavBarProvider) => bottomNavBarProvider.activePage,
      builder: (ctx, activePage, child) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 69,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Icon 1
            BarItem(
              icon: Icons.library_books_outlined,
              label: "Home",
              page: PageType.COLLECTIONS,
              pageController: pageController,
            ),

            //Icon 2
            BarItem(
              icon: Icons.menu_book_outlined,
              label: "Library",
              page: PageType.GENRES,
              pageController: pageController,
            ),

            //Icon 3
            BarItem(
              icon: Icons.person_pin_outlined,
              label: "Authors",
              page: PageType.AUTHORGALLERY,
              pageController: pageController,
            ),

            //Icon 4
            BarItem(
              icon: Icons.book_outlined,
              label: "Bookshelf",
              page: PageType.BOOKSHELF,
              pageController: pageController,
            ),

            //Icon 5
            BarItem(
              icon: Icons.person_outline,
              label: "Profile",
              page: PageType.PROFILE,
              pageController: pageController,
            ),
          ],
        ),
      ),
    );
  }
}

class BarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final PageType page;
  final PageController pageController;

  // SỬA LỖI: Cập nhật cú pháp constructor
  const BarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.page,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final bottomBarProvider = Provider.of<BottomNavBarProvider>(context);
    final active = bottomBarProvider.isActivePage(page);
    return InkWell(
      onTap: () {
        if (active) return;
        bottomBarProvider.setActivePage(page);
        pageController.animateToPage(
          bottomBarProvider.getPageNumber(page),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      },
      // Bỏ các hiệu ứng splash/highlight để trông gọn gàng hơn
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor.withOpacity(active ? 1 : 0.4),
            size: 25,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
              Theme.of(context).primaryColor.withOpacity(active ? 1 : 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}