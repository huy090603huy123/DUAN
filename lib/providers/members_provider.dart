import 'dart:collection';

import 'package:flutter/material.dart';
// Sửa import không cần thiết, vì `genre.dart` không được dùng trực tiếp ở đây
// import 'package:warehouse/models/genre.dart';
import '../models/genre.dart'; // Giả sử đường dẫn đúng là thế này

import '../utils/helper.dart';
import '../services/repositories/data_repository.dart';
import '../models/member.dart';

class MembersProvider with ChangeNotifier {
  final DataRepository _dataRepository;

  int? _mId; // Thay đổi: cho phép _mId là null một cách tường minh

  bool _loggedIn = false;

  final Map<int, Member> _members = Map();

  List<Genre> _memberPreferences = [];
  List<Genre> _tempPreferences = [];

  UnmodifiableMapView<int, Member> get membersMap => UnmodifiableMapView(_members);

  UnmodifiableListView<Member> get members => UnmodifiableListView(_members.values);
  UnmodifiableListView<Genre> get memberPreferences => UnmodifiableListView(_memberPreferences);

  // SỬA LỖI 1: Thay đổi kiểu trả về thành Member? (có thể null)
  Member? get currentMember => _members[_mId];

  bool get loggedIn => _loggedIn;

  int? get currentMId => _mId; // Kiểu trả về cũng nên là int?

  // SỬA LỖI 2: Thay @required bằng required
  MembersProvider({required DataRepository dataRepository}) : _dataRepository = dataRepository {
    _initializeData();
  }

  void _initializeData() {
    _initializeMembersMap();
  }

  void _initializeMembersMap() {
    _dataRepository.membersStream().listen((members) {
      for (var member in members) {
        _members[member.id] = member;
      }
      notifyListeners();
    });
  }

  // SỬA LỖI 2: Thay @required bằng required
  void signIn({required String email, required String password}) {
    _members.forEach((mId, member) {
      if (member.email == email && member.password == password) {
        _mId = member.id;
        _loggedIn = true;
        notifyListeners();
        return; // return ở đây chỉ thoát khỏi forEach, không thoát khỏi hàm
      }
    });
  }

  // SỬA LỖI 2: Thay @required bằng required
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
  }) async {
    final startDate = DateTime.now();
    final bio = "New enthusiastic member";
    final newMember = {
      "m_first_name": firstName,
      "m_last_name": lastName,
      "m_age": age,
      "m_bio": bio,
      "m_start_date": Helper.dateSerializer(startDate),
      "m_email": email,
      "m_password": password,
    };

    final newMId = await _dataRepository.createAccount(data: newMember);

    // Thêm kiểm tra null an toàn
    if (newMId != null) {
      _members[newMId] = Member(
          id: newMId,
          firstName: firstName,
          lastName: lastName,
          bio: bio,
          age: age,
          email: email,
          password: password,
          startDate: startDate);

      _mId = newMId;
      _loggedIn = true;
      notifyListeners();
    }
  }

  void toggleGenre(bool inActive, Genre genre) {
    inActive ? _tempPreferences.add(genre) : _tempPreferences.remove(genre);
  }

  setMemberPreferences(List<Genre> prefs) {
    _memberPreferences = [...prefs];
    _tempPreferences = [...prefs];
  }

  Future<void> changeMemberPreferences() async {
    // Không nên chạy các lệnh await song song trong forEach
    // Tách vòng lặp để tránh lỗi race condition
    final List<Future> deleteFutures = [];
    for (var genre in _memberPreferences) {
      if (!_tempPreferences.contains(genre)) {
        deleteFutures.add(_dataRepository.deleteMemberPreferences(id: "$_mId,${genre.id}"));
      }
    }
    await Future.wait(deleteFutures);

    final List<Future> addFutures = [];
    for (var genre in _tempPreferences) {
      if (!_memberPreferences.contains(genre)) {
        Map<String, dynamic> data = {
          "m_id": currentMId,
          "g_id": genre.id,
        };
        addFutures.add(_dataRepository.changeMemberPreferences(data: data));
      }
    }
    await Future.wait(addFutures);

    _memberPreferences = [..._tempPreferences];
    notifyListeners();
  }

  bool isPreference(Genre genre) => _tempPreferences.contains(genre);

  resetTempPreferences() {
    _tempPreferences = [..._memberPreferences];
    notifyListeners();
  }

  // SỬA LỖI 3: Cập nhật hàm để xử lý currentMember có thể null
  Future<bool> changeProfileData({String? email, String? password, String? bio, int? age}) async {
    final member = currentMember;
    // Thêm Guard Clause để kiểm tra null
    if (member == null) {
      return false;
    }

    Member temp = member.copyWith(email: email, password: password, bio: bio, age: age);
    int? mId = await _dataRepository.changeAccountData(data: temp.toJson(), id: _mId!);
    if (mId != null) {
      _members[_mId!] = temp;
      notifyListeners();
      return true;
    }
    return false;
  }
}