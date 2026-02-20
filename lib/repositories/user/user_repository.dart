import '../../models/user/user_model.dart';

abstract class UserRepository {
  Stream<UserModel> getCurrentUser();
}
