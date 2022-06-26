import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AuthService auth = AuthService();

  setUp(() {});

  //testing sign in anonymous
  test('Sign in anonymously', () async {
    var result = await auth.signInAnonymous();
    expect(result, isNot(null));
  });

  //testing deleting account for anonymous user
  test('Delete anonymous account', () async {
    var result = await auth.deleteAnonymousUser();
    expect(result, 'Success');
  });

  //testing sign out anonymous
  test('Sign out anonymously', () async {
    var result = await auth.signOut();
    expect(result, null);
    expect(auth.currentUser, null);
  });

  //testing account creation
  test('Creating account', () async {
    var result = await auth.register(
        'testcases', '12345678', 'testcases@gmail.com', 'User', 'testcases');
    expect(result, isNot(null));
  });

  //testing if user is in database
  test('User in database', () async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('UserInfo')
        .doc(auth.currentUser!.uid)
        .get();
    expect(snapshot.get('name'), 'testcases');
  });

  //test user login
  test('Logging in', () async {
    var result = auth.signIn('testcases', 'testcases');
    expect(result, isNot(null));
    expect(auth.currentUser, isNot(null));
  });

  //test duplicate account creation fails due to same details
  test('Creating account', () async {
    var result = await auth.register(
        'testcases', '12345678', 'testcases@gmail.com', 'User', 'testcases');
    expect(result, null);
  });

  //test updating details
  test('Update details', () async {
    var result = await auth.updateDetails('testcases2', '87654321');
    expect(result, isNot(null));
    expect(auth.currentUser, isNot(null));
  });

  //test if user is updated in database
  test('User updated in database', () async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('UserInfo')
        .doc(auth.currentUser!.uid)
        .get();
    expect(snapshot.get('name'), 'testcases2');
  });

  //test deleting user account
  test('Deleting account', () async {
    var result = await auth.deleteUser();
    expect(result, 'Success');
  });

  //test user not in database after deletion
  test('User not in database', () async {
    // ignore: prefer_typing_uninitialized_variables
    var result;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('UserInfo')
          .doc(auth.currentUser!.uid)
          .get();
      result = snapshot.exists;
    } catch (e) {
      result = 'No such user!';
    }
    expect(result, 'No such user!');
  });

  //test logging out user account
  test('Logging out account', () async {
    var result = await auth.signOut();
    expect(result, null);
    expect(auth.currentUser, null);
  });

  tearDown(() {});
}
