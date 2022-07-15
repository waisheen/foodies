import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodies/SellerMenu/addmenuitem.dart';

import '../Models/menu.dart';
import '../Models/shop.dart';
import '../Services/auth.dart';
import '../loading.dart';
import '../reusablewidgets.dart';

class SellerMenuPage extends StatefulWidget {
  const SellerMenuPage({Key? key, required this.shop, required this.showBackButton}) : super(key: key);
  final Shop? shop;
  final bool showBackButton;

  @override
  State<SellerMenuPage> createState() => _SellerMenuPageState();
}

class _SellerMenuPageState extends State<SellerMenuPage> {
  final AuthService _auth = AuthService();
  final CollectionReference menus = FirebaseFirestore.instance.collection("Menu");

  late bool isOwner = widget.shop!.sellerID == _auth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return widget.shop == null ? 
    noShopText(context) :
    Scaffold(
      body: StreamBuilder(
        stream: menus.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Loading();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverAppBar(
                  leading: widget.showBackButton ? TextButton.icon(
                    icon: const Icon(Icons.chevron_left, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                    label: Container(),
                  ) : null,
                  floating: true,
                  backgroundColor: Colors.white,
                  title: Text("Menu", style: TextStyle(color: themeColour, fontSize: 30))
                  ),
                SliverGrid(
                  delegate: SliverChildListDelegate(
                    menuList(snapshot.data!.docs, context, isOwner, widget.shop!.uid)
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }  
}

List<Widget> menuList(List<QueryDocumentSnapshot<Object?>> docsList, BuildContext context, bool canEdit,
  String shopID) {
  List filtered = docsList
      .map((document) => Menu.fromSnapshot(document))
      .where((menu) => menu.shop_id == shopID)
      .toList();

  List<Widget> widgetList = filtered.map((menu) => menuWidget(menu, context, canEdit)).toList();
  
  if (canEdit) {
    widgetList.add(
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        child: bigButton(
          "Add Menu Item",
          () async {
            //goes to add menu item page
            await getSellerShop().then((shop) => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddMenuItemPage(shop: shop))));
          },
        ),
      ),
    );
  }
  return widgetList;
}

Widget menuWidget(Menu item, BuildContext context, bool canEdit) {
  return SizedBox(
    width: 150,
    child: Card(
      clipBehavior: Clip.hardEdge,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Image(
                image: NetworkImage(item.imageURL),
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  //placeholder picture in the case image cannot be displayed
                  return const Image(
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    image: AssetImage('assets/images/logo5.png'),
                  );
                },
              ),
              canEdit ? 
              Padding(
                padding: const EdgeInsets.all(2),
                child: GestureDetector(
                  onTap: () async {
                    //goes to add menu item page
                    await getSellerShop().then((shop) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddMenuItemPage(shop: shop, item: item))));
                  },
                  child: Icon(CupertinoIcons.pencil_circle_fill, 
                    color: Colors.blueGrey.withOpacity(0.7),
                    size: 30,
                  ),
                ),
              )
              : emptyBox(1)
            ],
          ),

          emptyBox(8),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(item.name, style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 5),
                Text("\$${item.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13)),
              ],
            ),
          )
          
        ],
      ),
    ),
  );
}