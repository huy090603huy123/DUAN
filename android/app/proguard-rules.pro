    # Quy tắc chung để giữ lại các phần quan trọng của ứng dụng Flutter và Android

    # Giữ lại các lớp liên quan đến Flutter Engine
    -keep class io.flutter.app.** { *; }
    -keep class io.flutter.plugin.** { *; }
    -keep class io.flutter.view.** { *; }
    -keep class io.flutter.** { *; }

    # Giữ lại MainActivity của ứng dụng của bạn
    # Đảm bảo tên gói và tên lớp chính xác
    -keep class com.example.warehouse.MainActivity { *; }

    # Giữ lại các lớp mô hình dữ liệu (models) nếu chúng được sử dụng bởi các thư viện JSON serialization
    # hoặc được truy cập bằng reflection (ví dụ: Firebase Firestore, JSON parsing)
    # Thay thế 'com.example.warehouse.models' bằng đường dẫn thực tế của các lớp model của bạn
    -keep class com.example.warehouse.models.** { *; }

    # Quy tắc cho Firebase (nếu bạn sử dụng Firebase trong dự án)
    # Các quy tắc này giúp đảm bảo Firebase hoạt động đúng sau khi obfuscate
    -keep class com.google.firebase.** { *; }
    -keep class com.google.android.gms.** { *; }
    -dontwarn com.google.android.gms.**

    # Quy tắc cho OneSignal (nếu bạn sử dụng OneSignal)
    -keep class com.onesignal.** { *; }
    -dontwarn com.onesignal.**

    # Quy tắc cho các thư viện khác (ví dụ: nếu bạn sử dụng Retrofit, Room, v.v.)
    # Luôn kiểm tra tài liệu của thư viện để tìm các quy tắc ProGuard cần thiết

    # Giữ lại các enum nếu chúng được sử dụng trong switch statements hoặc reflection
    -keepclassmembers enum * {
        public static **[] values();
        public static ** valueOf(java.lang.String);
    }

    # Giữ lại các lớp có chú thích (annotations) nếu chúng được sử dụng bởi reflection
    -keepattributes InnerClasses
    -keepattributes Signature
    -keepattributes *Annotation*
    