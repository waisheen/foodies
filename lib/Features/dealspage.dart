import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({Key? key}) : super(key: key);

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
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
              style: TextStyle(color: Colors.red, fontSize: 35.0),
            ),
          ],
        ),
      ),
    );
  }
}
