import 'package:flutter/material.dart';
import 'package:foodies/ProfilePage/sellerprofilepage.dart';
import 'package:foodies/ProfilePage/userprofilepage.dart';
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
    const FilterPage(),
    const UserProfilePage()
  ];
  PageController pageController = PageController();
  int currentIndex = 0;
  final Color colour = Colors.teal.shade600;

  void onTapped(int index) {
    setState(() => currentIndex = index);
    pageController.animateToPage(index, duration: const Duration(seconds: 1), 
      curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colour,
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
          ),
        ],
      ),
      
      backgroundColor: Colors.white,
      body: PageView(
        controller: pageController,
        children: const [
          SearchPage(),
          DealsPage(),
          LocationPage(),
          FilterPage(),
          //(func to check if user signed in) => go to log in page, or else
          //(func to get user role) == "User" ? UserProfilePage() : SellerProfilePage()
          UserProfilePage()
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
              icon: Icon(Icons.search_outlined),
              label: 'Search'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.discount_outlined),
              label: 'Deals'
          ),
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
