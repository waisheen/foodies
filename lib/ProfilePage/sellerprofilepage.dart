import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({Key? key}) : super(key: key);

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final AuthService _auth = AuthService();
  int currentIndex = 0;
  Color color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 150.0,
            ),
            Center(
              child: Text(
                "seller: ${_auth.currentUser!.uid}",
                style: TextStyle(
                  color: color,
                  fontSize: 30.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
