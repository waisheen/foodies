import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import '../Features/all.dart';
import '../ProfilePage/profilepage.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({Key? key}) : super(key: key);

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  final AuthService _auth = AuthService();
  PageController pageController = PageController();
  int currentIndex = 0;
  final Color colour = Colors.teal.shade600;

  void onTapped(int index) {
    setState(() => currentIndex = index);
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colour,
        title: const Image(
          image: AssetImage('assets/images/logo_white.png'),
          height: 50,
        ),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.account_circle_rounded, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: const [
          SearchPage(),
          UserPromotionPage(),
          LocationPage(),
          FilterPage(),
          ProfilePage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: currentIndex,
        selectedItemColor: colour,
        unselectedItemColor: Colors.grey.shade700,
        onTap: onTapped,
        selectedFontSize: 10.0,
        backgroundColor: colour,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.discount_outlined), label: 'Deals'),
          BottomNavigationBarItem(
            icon: Icon(Icons.place_outlined),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_alt_outlined),
            label: 'Filter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
