import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodies/Services/database.dart';
import '../Models/appuser.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Creating user object
  AppUser? _userFromFirebase(User? user) {
    return user != null
        ? AppUser(uid: user.uid, isAnonymous: user.isAnonymous)
        : null;
  }

  //Returning appUser
  AppUser? get currentUser {
    return _userFromFirebase(_auth.currentUser);
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
      return 'Error';
    }
  }

  //Register user with email & password
  Future register(String name, String contact, String email, String role,
      String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      await DatabaseService(uid: user!.uid)
          .addUser(name, int.parse(contact), email, role);
      return _userFromFirebase(user);
    } catch (e) {
      return null;
    }
  }

  //Register seller with email & password
  Future registerSeller(String name, String contact, String email, String role,
      String password, List<String> shops) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      await DatabaseService(uid: user!.uid)
          .addUser(name, int.parse(contact), email, role);
      await DatabaseService(uid: user.uid)
          .addRequest(name, contact, email, user.uid, shops);
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

  //Reset password
  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  //Update name and contact
  Future updateDetails(String name, String contact) async {
    try {
      await DatabaseService(uid: _auth.currentUser!.uid)
          .updateUser(name, int.parse(contact));
      return _userFromFirebase(_auth.currentUser);
    } catch (e) {
      return null;
    }
  }

  //Deleting user
  Future deleteUser() async {
    try {
      User user = _auth.currentUser!;
      await FirebaseFirestore.instance
          .collection('UserInfo')
          .doc(user.uid)
          .delete();
      await user.delete();
      return 'Success';
    } catch (e) {
      return null;
    }
  }

  //Deleting anonymous user
  Future deleteAnonymousUser() async {
    try {
      User user = _auth.currentUser!;
      await user.delete();
      return 'Success';
    } catch (e) {
      return null;
    }
  }
}
