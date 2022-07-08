import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/reusablewidgets.dart';
import 'package:foodies/theme.dart';

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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text("Don't have an account yet?",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeColour,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            emptyBox(20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text("Sign up now to access more features such as leaving reviews, and more! :D",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),

            emptyBox(60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90.0),
              child: bigButton('Sign up', () {
                // _auth.signOut();
                _auth.deleteAnonymousUser();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
