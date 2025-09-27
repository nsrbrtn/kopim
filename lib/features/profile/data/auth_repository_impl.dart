import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmail(String email, String password);
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;  // Добавлен тип

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user;
  }

  @override
  Future<void> signOut() async => await _auth.signOut();
}