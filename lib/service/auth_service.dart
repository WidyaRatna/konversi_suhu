import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar.';
        case 'wrong-password':
          return 'Password salah.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti.';
        default:
          return 'Login gagal: ${e.message}';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}