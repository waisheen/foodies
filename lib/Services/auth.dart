import 'package:firebase_auth/firebase_auth.dart';
import '../Models/appuser.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Creating user object
  AppUser? _userFromFirebase(User user, String type) {
    return AppUser(uid: user.uid, type: type);
  }

  //Signing in as guest
  Future signInAnonymous() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebase(user!, 'Guest');
    } catch (e) {
      rethrow;
    }
  }
}
