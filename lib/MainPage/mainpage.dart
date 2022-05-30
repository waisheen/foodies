import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import '../Features/all.dart';
import 'functions.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AuthService _auth = AuthService();
  final screens = [
    const SearchPage(),
    const DealsPage(),
    const LocationPage(),
    const FilterPage()
  ];
  int currentIndex = 0;
  Color color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
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

            /*onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()));
            },*/
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          setState(() => color = setColor(index));
        },
        selectedFontSize: 15.0,
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined, color: Colors.black),
              label: 'Search',
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.discount_outlined, color: Colors.black),
              label: 'Deals',
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
              icon: Icon(Icons.place_outlined, color: Colors.black),
              label: 'Location',
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: Icon(Icons.filter_alt_outlined, color: Colors.black),
              label: 'Filter',
              backgroundColor: Colors.amber),
        ],
      ),
    );
  }
}
