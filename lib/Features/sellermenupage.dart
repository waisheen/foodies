import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';

class SellerMenuPage extends StatefulWidget {
  const SellerMenuPage({Key? key}) : super(key: key);

  @override
  State<SellerMenuPage> createState() => _SellerMenuPageState();
}

class _SellerMenuPageState extends State<SellerMenuPage> {
  // ignore: unused_field
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
            Container(height: 200),
            const Text(
              'Coming to you soon!',
              style: TextStyle(color: Colors.amber, fontSize: 35.0),
            ),
          ],
        ),
      ),
    );
  }
}
