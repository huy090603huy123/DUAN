// duan/lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // --- BẢNG MÀU ---
  static const Color primaryColor = Color(0xFF388E3C); // Xanh lá cây đậm
  static const Color secondaryColor = Color(0xFFE8F5E9); // Xanh lá cây nhạt (sẽ là màu nền)
  static const Color accentColor = Color(0xFFFFC107); // Màu vàng cho điểm nhấn
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Color(0xFF333333); // Màu chữ chính
  static const Color cardBackgroundColor = Colors.white;
  static const Color backgroundColor = secondaryColor; // Giữ nguyên màu nền xanh nhạt

  // --- THEME CHÍNH (ĐÃ ĐƯỢC TINH CHỈNH) ---
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: backgroundColor, // Nền xanh nhạt
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor, // Dùng màu vàng làm màu phụ cho các widget khác
      background: backgroundColor,
      surface: cardBackgroundColor, // Bề mặt các card là màu trắng
      onPrimary: whiteColor, // Chữ trên nền primary (xanh đậm) là màu trắng
      onSecondary: blackColor, // Chữ trên nền secondary (vàng) là màu đen
      onBackground: blackColor, // Chữ trên nền chính (xanh nhạt) là màu đen
      onSurface: blackColor,    // Chữ trên card (trắng) là màu đen
      error: Colors.redAccent,
    ),
    appBarTheme: AppBarTheme(
      // SỬA Ở ĐÂY: Dùng nền trắng cho AppBar để giao diện sạch sẽ, thoáng đãng hơn
      backgroundColor: whiteColor,
      elevation: 1, // Thêm một chút đổ bóng để phân tách với nội dung
      shadowColor: Colors.black.withOpacity(0.1),
      iconTheme: const IconThemeData(color: blackColor), // Icon màu đen trên AppBar trắng
      titleTextStyle: GoogleFonts.nunito(
        color: blackColor, // Tiêu đề màu đen trên AppBar trắng
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      // SỬA Ở ĐÂY: Dùng màu đen/xám đậm cho dễ đọc trên nền xanh nhạt và trắng
      headlineLarge: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 24.0, color: blackColor),
      headlineMedium: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 20.0, color: blackColor),
      bodyLarge: GoogleFonts.nunito(fontSize: 16.0, color: blackColor),
      bodyMedium: GoogleFonts.nunito(fontSize: 14.0, color: Colors.grey[800]), // Dùng màu xám rất đậm cho nội dung phụ
      labelLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: whiteColor), // Dành cho Button
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: whiteColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[500],
      selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: GoogleFonts.nunito(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
  );
}