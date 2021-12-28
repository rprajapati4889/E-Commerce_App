import 'package:firebase_auth/firebase_auth.dart';

import '../entities/seller_entity.dart';

abstract class FirebaseAuthRepository {
  Future<User> get loggedFirebaseSeller;
  String get authException;

  Future<void> signUp(SellerEntity newSeller, String password);

  Future<void> logInWithEmailAndPassword(String email, String password);

  Future<bool> isLoggedIn();

  Future<void> logOut();
}