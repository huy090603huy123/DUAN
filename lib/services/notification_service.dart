import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  // --- THAY THẾ BẰNG THÔNG TIN CỦA BẠN TỪ DASHBOARD ONESIGNAL ---
  static const String _appId = "b865664d-e105-4fed-85f4-36095f0b2072";
  // CẢNH BÁO: Không lưu key này ở client trong môi trường production!
  static const String _restApiKey = "os_v2_app_xbswmtpbavh63bpugyev6czaoic66fx6sdregde5lvxcrhyvmcwpup3ig2pc6mlrdp5f2z4xuuffntmbow3jk65hs5fhkelmpyjt6ba";

  /// Khởi tạo OneSignal SDK
  static Future<void> initOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(_appId);
    // Yêu cầu quyền gửi thông báo (quan trọng cho iOS)
    await OneSignal.Notifications.requestPermission(true);
  }

  /// Gắn ID người dùng của bạn với OneSignal
  static void loginUser(String userId) {
    OneSignal.login(userId);
  }

  /// Gỡ bỏ ID người dùng khi đăng xuất
  static void logoutUser() {
    OneSignal.logout();
  }

  /// Gửi thông báo đến một người dùng cụ thể thông qua REST API
  static Future<void> sendNotificationToUser({
    required String targetUserId,
    required String title,
    required String content,
  }) async {
    final url = Uri.parse('https://api.onesignal.com/notifications');

    final body = {
      "app_id": _appId,
      // Target người dùng cụ thể bằng ID của bạn
      "include_external_user_ids": [targetUserId],
      "channel_for_external_user_ids": "push",
      // Nội dung thông báo
      "headings": {"en": title},
      "contents": {"en": content},
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          // Sử dụng REST API Key để xác thực
          'Authorization': 'Basic $_restApiKey',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print("Gửi thông báo thành công đến user: $targetUserId");
      } else {
        print("Gửi thông báo thất bại: ${response.statusCode}");
        print("Lý do: ${response.body}");
      }
    } catch (e) {
      print("Lỗi khi gửi thông báo: $e");
    }
  }
}
