import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
            const SizedBox(
              height: 25.0,
            ),
            Padding(
              //choose user type
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search a shop',
                ),
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: Container(
                color: Colors.transparent,
                child: const Text(
                  '  Recommendations',
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Container(
              height: 20,
            ),
            Container(
              height: 200,
              width: 350,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/caawow.png'),
                fit: BoxFit.cover,
              )),
            ),
            Container(height: 20),
            Container(
              height: 200,
              width: 350,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/wangs.png'),
                fit: BoxFit.cover,
              )),
            ),
            Container(height: 20),
            Container(
              height: 200,
              width: 350,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/pastafast.png'),
                fit: BoxFit.cover,
              )),
            ),
            Container(height: 20),
          ],
        ),
      ),
    );
  }
}