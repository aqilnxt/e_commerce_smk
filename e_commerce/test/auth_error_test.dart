import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce/app/core/services/auth_service.dart';

void main() {
  test('kode error Firebase diterjemahkan ke Bahasa Indonesia', () {
    String map(String code) => AuthService.mapFirebaseAuthError(FirebaseAuthException(code: code));
    expect(map('email-already-in-use'), 'Email ini sudah terdaftar. Silakan login.');
    expect(map('invalid-credential'), 'Email atau kata sandi salah.');
    expect(map('wrong-password'), map('invalid-credential'));
    expect(map('operation-not-allowed'), contains('Firebase Console'));
    expect(AuthService.mapFirebaseAuthError(Exception('x')), contains('tak terduga'));
  });
}
