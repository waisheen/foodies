import 'package:firebase_auth/firebase_auth.dart';
import '../Models/appuser.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Creating user object
  AppUser? _userFromFirebase(User? user) {
    return user != null
        ? AppUser(uid: user.uid, isAnonymous: user.isAnonymous)
        : null;
  }

  //auth change appuser stream
  Stream<AppUser?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebase(user));
  }

  //Signing in as guest
  Future signInAnonymous() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      return null;
    }
  }

  //Signing out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  //Register with email & password
  Future register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      return null;
    }
  }

  //Signing in
  Future signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      return null;
    }
  }
}
