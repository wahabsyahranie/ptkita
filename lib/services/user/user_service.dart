import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user/user_model.dart';
import '../../repositories/user/user_repository.dart';

class UserService {
  final UserRepository repository;

  UserService(this.repository);

  /// Stream auth state
  Stream<User?> get authState => repository.authStateChanges();

  /// Stream profile user berdasarkan auth state
  Stream<UserModel?> get currentUserProfile =>
      repository.authStateChanges().asyncExpand((user) {
        if (user == null) {
          return Stream.value(null);
        }
        return repository.getUserProfile(user.uid);
      });

  /// Logout
  Future<void> logout() => repository.signOut();
}
