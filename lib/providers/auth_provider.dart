import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  Future<bool> login(String id, String password) async {
    // 더미 데이터로 로그인 체크
    if (id == 'test' && password == '1234') {
      state = true;
      return true;
    }
    return false;
  }

  Future<bool> signup(
      String id, String password, String name, String email) async {
    // 더미 데이터로 회원가입 처리
    // 실제로는 API 호출을 통해 처리해야 함
    if (id.isNotEmpty &&
        password.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty) {
      // 회원가입 성공으로 가정
      return true;
    }
    return false;
  }

  void logout() {
    state = false;
  }
}
