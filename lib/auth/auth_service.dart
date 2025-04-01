import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential?> loginWithGoogle() async {
    try {
      log('Bắt đầu đăng nhập với Google');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email'],
        signInOption: SignInOption.standard,
      ).signIn();

      if (googleUser == null) {
        log('Người dùng hủy đăng nhập Google');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        log('Không nhận được ID token từ Google');
        throw AuthException("Không thể xác thực với Google. Vui lòng thử lại.");
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in to Firebase with the Google credential
      log('Đang xác thực với Firebase');
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        log('Không nhận được thông tin người dùng từ Firebase');
        throw AuthException(
            "Không thể lấy thông tin người dùng. Vui lòng thử lại.");
      }

      log('Đăng nhập Google thành công: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log('Lỗi Firebase khi đăng nhập Google: ${e.code} - ${e.message}');
      throw AuthException(exceptionHandler(e.code));
    } catch (e) {
      log('Lỗi không xác định khi đăng nhập Google: $e');
      throw AuthException(
          "Đã xảy ra lỗi khi đăng nhập với Google. Vui lòng thử lại.");
    }
  }

  Future<void> sendEmailVerificationLink() async {
    try {
      log('Đang gửi email xác nhận...');
      await _auth.currentUser?.sendEmailVerification();
      log('Đã gửi email xác nhận thành công');
    } catch (e) {
      log('Lỗi gửi email xác nhận: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetLink(String email) async {
    try {
      log('Đang gửi email đặt lại mật khẩu đến: $email');
      await _auth.sendPasswordResetEmail(email: email);
      log('Đã gửi email đặt lại mật khẩu thành công');
    } catch (e) {
      log('Lỗi gửi email đặt lại mật khẩu: $e');
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      log('Đang tạo tài khoản với email: $email');
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      log('Tạo tài khoản thành công: ${cred.user?.email}');

      // Gửi email xác nhận ngay sau khi tạo tài khoản
      await cred.user?.sendEmailVerification();
      log('Đã gửi email xác nhận đến: ${cred.user?.email}');

      return cred.user;
    } on FirebaseAuthException catch (e) {
      log('Lỗi Firebase khi đăng ký: ${e.code} - ${e.message}');
      throw AuthException(exceptionHandler(e.code));
    } catch (e) {
      log('Lỗi không xác định khi đăng ký: $e');
      throw AuthException("Đã xảy ra lỗi không xác định: $e");
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      log('Đang đăng nhập với email: $email');
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      log('Đăng nhập thành công cho tài khoản: ${cred.user?.email}');
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log('Lỗi Firebase khi đăng nhập: ${e.code} - ${e.message}');
      throw AuthException(exceptionHandler(e.code));
    } catch (e) {
      log('Lỗi không xác định khi đăng nhập: $e');
      throw AuthException("Đã xảy ra lỗi không xác định: $e");
    }
  }

  Future<void> signout() async {
    try {
      log('Đang đăng xuất tài khoản: ${_auth.currentUser?.email}');
      await _auth.signOut();
      log('Đăng xuất thành công');
    } catch (e) {
      log('Lỗi khi đăng xuất: $e');
      rethrow;
    }
  }
}

String exceptionHandler(String code) {
  switch (code) {
    case "invalid-credential":
      return "Email hoặc mật khẩu không chính xác";
    case "weak-password":
      return "Mật khẩu phải có ít nhất 8 ký tự";
    case "email-already-in-use":
      return "Email đã được sử dụng";
    case "user-not-found":
      return "Không tìm thấy tài khoản với email này";
    case "wrong-password":
      return "Mật khẩu không chính xác";
    case "invalid-email":
      return "Email không hợp lệ";
    case "too-many-requests":
      return "Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau";
    case "operation-not-allowed":
      return "Phương thức đăng nhập này không được cho phép";
    case "user-disabled":
      return "Tài khoản này đã bị vô hiệu hóa";
    case "network-request-failed":
      return "Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet";
    case "internal-error":
      return "Lỗi hệ thống. Vui lòng thử lại sau";
    default:
      return "Đã xảy ra lỗi không xác định";
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
