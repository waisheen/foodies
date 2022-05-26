import 'package:flutter/material.dart';
import 'Login/all.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodies',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.cyan,
      ),
      home: const LoginPage(title: 'Login Page'),
    );
  }
}
