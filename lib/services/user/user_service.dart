import '../../models/user/user_model.dart';
import '../../repositories/user/user_repository.dart';

class UserService {
  final UserRepository repository;

  UserService(this.repository);

  Stream<UserModel> currentUser() => repository.getCurrentUser();
}
