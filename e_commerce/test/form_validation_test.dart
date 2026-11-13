import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce/app/modules/login/controllers/login_controller.dart';
import 'package:e_commerce/app/modules/register/controllers/register_controller.dart';

void main() {
  final login = LoginController();

  test('email wajib diisi dan harus sesuai format', () {
    expect(login.validateEmail(''), 'Alamat email wajib diisi');
    expect(login.validateEmail('siswa.sekolah'), isNotNull);
    expect(login.validateEmail('siswa@sekolah.sch.id'), isNull);
  });

  test('sandi minimal 6 karakter dan wajib ada angka', () {
    expect(login.validatePassword('abc1'), 'Kata sandi minimal 6 karakter');
    expect(login.validatePassword('sepatubaru'), 'Kata sandi harus mengandung minimal 1 angka (0-9)');
    expect(login.validatePassword('sepatubaru1'), isNull);
  });

  test('register: nama minimal 3 huruf dan konfirmasi sandi harus sama', () {
    final register = RegisterController()..onInit();
    addTearDown(register.onClose);
    expect(register.validateName('Al'), 'Nama minimal 3 karakter');
    expect(register.validatePassword('rahasia'), 'Kata sandi harus mengandung minimal 1 angka (0-9)');
    register.passwordController.text = 'rahasia1';
    expect(register.validateConfirmPassword('rahasia2'), 'Konfirmasi kata sandi tidak cocok');
    expect(register.validateConfirmPassword('rahasia1'), isNull);
  });
}
