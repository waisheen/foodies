import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[300],
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.account_circle_rounded, color: Colors.black),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 150.0,
            ),
            Center(
              child: Text(
                'Main Page',
                style: TextStyle(
                  color: Colors.cyan[300],
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
