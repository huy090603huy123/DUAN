import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warehouse/models/genre.dart';
import 'package:warehouse/models/member.dart';
import 'package:warehouse/services/repositories/data_repository.dart';
import 'package:warehouse/utils/enums/status_enum.dart';

class MembersProvider with ChangeNotifier {
  final DataRepository _dataRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Status _status = Status.INITIAL;
  Status get status => _status;

  // Không cần thiết phải lưu _firebaseUser ở đây,
  // listener đã có thể truy cập qua _auth.currentUser
  Member? _memberProfile;
  Member? get member => _memberProfile;

  // --- THAY ĐỔI QUAN TRỌNG #1 ---
  // Định nghĩa lại `isLoggedIn`. Một người dùng chỉ thực sự đăng nhập
  // khi trạng thái là AUTHENTICATED và profile của họ đã được tải thành công.
  bool get isLoggedIn => _status == Status.AUTHENTICATED && _memberProfile != null;
  bool get isAdmin => _memberProfile?.role == 'admin';

  Set<String> _tempPreferredGenreIds = {};

  MembersProvider({required DataRepository dataRepository})
      : _dataRepository = dataRepository {
    // Luồng xử lý state tập trung hoàn toàn vào listener này
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    print("DEBUG: Trạng thái đăng nhập thay đổi. User is ${user?.uid}");
    if (user == null) {
      _status = Status.UNAUTHENTICATED;
      _memberProfile = null;
      _tempPreferredGenreIds.clear();
      print("DEBUG: Người dùng đã đăng xuất.");
      notifyListeners(); // Thông báo cho UI về việc đăng xuất
      return;
    }

    // Nếu có user, bắt đầu quá trình tải profile
    _status = Status.LOADING;
    notifyListeners(); // Thông báo cho UI rằng chúng ta đang tải dữ liệu

    try {
      print("DEBUG: Đang tải profile cho user ID: ${user.uid}...");
      _memberProfile = await _dataRepository.getUserProfile(user.uid);

      if (_memberProfile != null) {
        print("DEBUG: Tải profile thành công! Tên: ${_memberProfile?.memberName}");
        _initPreferences();
        _status = Status.AUTHENTICATED;
      } else {
        // Xử lý trường hợp user tồn tại trong Firebase Auth nhưng không có trong DB
        print("DEBUG: !!! LỖI: Không tìm thấy profile cho user ${user.uid}");
        _status = Status.UNAUTHENTICATED;
        await _auth.signOut(); // Đăng xuất để tránh vòng lặp đăng nhập lỗi
      }
    } catch (e) {
      print("DEBUG: !!! LỖI KHI TẢI PROFILE: $e");
      _status = Status.UNAUTHENTICATED; // Đặt trạng thái lỗi
      _memberProfile = null;
      await _auth.signOut(); // Đăng xuất để tránh vòng lặp
    }

    // --- CỰC KỲ QUAN TRỌNG ---
    // Luôn gọi notifyListeners() lần cuối cùng sau khi tất cả công việc đã hoàn thành
    // để cập nhật UI với trạng thái cuối cùng.
    notifyListeners();
  }

  // --- THAY ĐỔI QUAN TRỌNG #2: Đơn giản hóa hàm signIn ---
  Future<void> signIn({required String email, required String password}) async {
    // Không cần quản lý status ở đây. Chỉ cần thực hiện hành động đăng nhập.
    // Listener _onAuthStateChanged sẽ lo phần còn lại một cách nhất quán.
    try {
      await _dataRepository.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print("Lỗi đăng nhập: ${e.message}");
      // Ném lại lỗi để lớp UI có thể bắt và hiển thị thông báo cho người dùng
      rethrow;
    }
  }

  // --- THAY ĐỔI QUAN TRỌNG #3: Đơn giản hóa hàm signUp ---
  Future<void> signUp(
      {required String email,
        required String password,
        required String firstName,
        required String lastName,
        required int age}) async {
    // Tương tự signIn, chỉ thực hiện hành động, không quản lý state ở đây
    try {
      UserCredential userCredential = await _dataRepository.signUpWithEmail(
          email: email, password: password);

      if (userCredential.user != null) {
        final newMemberData = {
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
          'email': email,
          'startDate': DateTime.now(),
          'imageUrl': null,
          'bio': '',
          'preferredGenreIds': [],
          'role': 'user',
        };

        await _dataRepository.createUserProfile(
            uid: userCredential.user!.uid, data: newMemberData);
        // Listener _onAuthStateChanged sẽ tự động được gọi sau khi đăng ký thành công
      }
    } on FirebaseAuthException catch (e) {
      print("Lỗi đăng ký: ${e.message}");
      rethrow;
    }
  }

  // Các hàm còn lại giữ nguyên
  Future<void> signOut() async {
    try {
      await _dataRepository.signOut();
    } catch (e) {
      print("Lỗi đăng xuất: $e");
    }
  }

  void _initPreferences() {
    if (_memberProfile != null) {
      _tempPreferredGenreIds =
      Set<String>.from(_memberProfile!.preferredGenreIds);
    } else {
      _tempPreferredGenreIds.clear();
    }
  }

  void resetTempPreferences() {
    _initPreferences();
    notifyListeners();
  }

  bool isPreference(Genre genre) {
    return _tempPreferredGenreIds.contains(genre.id);
  }

  void toggleGenre(bool value, Genre genre) {
    if (value) {
      _tempPreferredGenreIds.add(genre.id);
    } else {
      _tempPreferredGenreIds.remove(genre.id);
    }
  }

  // Các hàm changeMemberPreferences và changeProfileData giữ nguyên
  Future<void> changeMemberPreferences() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      _status = Status.LOADING;
      notifyListeners();

      final List<String> newPreferences = _tempPreferredGenreIds.toList();

      await _dataRepository.updateUserProfile(
        uid: user.uid,
        data: {'preferredGenreIds': newPreferences},
      );

      if (_memberProfile != null) {
        _memberProfile = Member(
            id: _memberProfile!.id,
            firstName: _memberProfile!.firstName,
            lastName: _memberProfile!.lastName,
            bio: _memberProfile!.bio,
            age: _memberProfile!.age,
            email: _memberProfile!.email,
            imageUrl: _memberProfile!.imageUrl,
            startDate: _memberProfile!.startDate,
            preferredGenreIds: newPreferences,
            role: _memberProfile!.role);
      }

      _status = Status.DONE;
    } catch (e) {
      print("Không thể cập nhật sở thích: $e");
      _status = Status.ERROR;
      resetTempPreferences();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> changeProfileData(
      {String? email, String? password, String? bio, int? age}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _status = Status.LOADING;
      notifyListeners();

      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
      }
      if (email != null && email.isNotEmpty) {
        await user.updateEmail(email);
      }

      final Map<String, dynamic> firestoreData = {};
      if (email != null && email.isNotEmpty) firestoreData['email'] = email;
      if (bio != null && bio.isNotEmpty) firestoreData['bio'] = bio;
      if (age != null) firestoreData['age'] = age;

      if (firestoreData.isNotEmpty) {
        await _dataRepository.updateUserProfile(
          uid: user.uid,
          data: firestoreData,
        );
      }
      await _onAuthStateChanged(user);
      return true;
    } on FirebaseAuthException catch (e) {
      print("Lỗi cập nhật profile (Auth): ${e.message}");
      _status = Status.ERROR;
      notifyListeners();
      return false;
    } catch (e) {
      print("Lỗi cập nhật profile: $e");
      _status = Status.ERROR;
      notifyListeners();
      return false;
    }
  }
}