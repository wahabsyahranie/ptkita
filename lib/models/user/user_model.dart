class UserModel {
  final String id;
  final String name;
  final String? photoUrl;
  final String? phone;

  UserModel({required this.id, required this.name, this.photoUrl, this.phone});
}
