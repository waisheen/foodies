import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import '../SearchPage/searchpage.dart';
import '../SellerMenu/sellermenupage.dart';
import '../Shop/shopdetails.dart';
import '../Models/shop.dart';
import '../Promotion/sellerpromotionpage.dart';
import '../ProfilePage/profilepage.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class SellerMainPage extends StatefulWidget {
  const SellerMainPage({Key? key}) : super(key: key);

  @override
  State<SellerMainPage> createState() => _SellerMainPageState();
}

class _SellerMainPageState extends State<SellerMainPage> {
  final AuthService _auth = AuthService();
  PageController pageController = PageController();
  int currentIndex = 0;
  final Color colour = Colors.teal.shade600;
    // ignore: avoid_init_to_null
  late Shop? shop;
  bool loading = true;

  @override
  initState() {
    super.initState();
    getSellerShop().then((result) {
      setState(() {
        shop = result;
        loading = false;
      });
    });
  }


  void onTapped(int index) {
    setState(() => currentIndex = index);
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : 
    Scaffold(
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
        children: [
          const SearchPage(),
          SellerPromotionPage(shop: shop),
          const SellerMenuPage(),
          ShopDetailsPage(shop: shop, showBackButton: false),
          const ProfilePage()
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
              icon: Icon(Icons.discount_outlined), label: 'My Promotions'),
          BottomNavigationBarItem(
            icon: Icon(Icons.ramen_dining),
            label: 'My Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'My Shop',
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
