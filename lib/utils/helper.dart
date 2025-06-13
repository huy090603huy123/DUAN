import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'enums/page_type_enum.dart';

class Helper {
  static final double hPadding = 20.0;
  static final bookPlaceholder = 'https://kimslater.com/wp-content/uploads/2010/08/blank-cover.png';

  // Đã sửa lỗi ở đây
  static navigateToPage({required BuildContext context, required PageType page, Object? arguments}) {
    Navigator.of(context).pushNamed(page.name, arguments: arguments);
  }

  static String dateSerializer(DateTime date) {
    // Để đảm bảo tính nhất quán, bạn có thể muốn sử dụng toUtc() trước khi định dạng
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(date.toUtc());
  }

  static DateTime? dateDeserializer(String? iso8601date) {
    if (iso8601date == null) return null;
    return DateTime.tryParse(iso8601date);
  }

  static String? datePresenter(DateTime? date) {
    if (date == null) return null;
    // Cân nhắc sử dụng toLocal() để hiển thị đúng múi giờ cho người dùng
    return DateFormat('d MMM, yyyy', 'vi_VN').format(date.toLocal());
  }
}