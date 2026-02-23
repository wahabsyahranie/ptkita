import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user/user_model.dart';

abstract class UserRepository {
  /// Stream auth state (login / logout)
  Stream<User?> authStateChanges();

  /// Logout
  Future<void> signOut();

  /// Ambil user profile berdasarkan uid
  Stream<UserModel> getUserProfile(String uid);
}
