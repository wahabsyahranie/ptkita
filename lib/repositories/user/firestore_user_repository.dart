import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user/user_model.dart';
import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreUserRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Stream<UserModel> getUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data() ?? {};

      return UserModel(
        id: uid,
        name: data['name'] ?? 'Teknisi',
        photoUrl: data['photoUrl'],
        phone: data['phone'],
      );
    });
  }
}
