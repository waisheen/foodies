import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/reusablewidgets.dart';

import '../Services/all.dart';

class AnonymousPage extends StatefulWidget {
  const AnonymousPage({Key? key}) : super(key: key);

  @override
  State<AnonymousPage> createState() => _AnonymousPageState();
}

class _AnonymousPageState extends State<AnonymousPage> {
  final AuthService _auth = AuthService();
  final CollectionReference userInformation =
      FirebaseFirestore.instance.collection('UserInfo');

  //When details are retrieved, update the profile page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 250.0,
            ),
            emptyBox(30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90.0),
              child: bigButton('Sign in', () {
                // _auth.signOut();
                _auth.deleteAnonymousUser();
              }),
            ),
            emptyBox(20.0),
          ],
        ),
      ),
    );
  }
}
