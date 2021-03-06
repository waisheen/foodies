import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Models/shop.dart';
import 'package:foodies/Services/all.dart';

import '../reusablewidgets.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({Key? key}) : super(key: key);

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final CollectionReference userInformation =
      FirebaseFirestore.instance.collection('UserInfo');
  final CollectionReference shops =
      FirebaseFirestore.instance.collection('Shop');

  bool editing = false;
  String name = 'Loading...';
  String contact = 'Loading...';

  _SellerProfilePageState() {
    init();
  }

  Future init() async {
    var result = await FirebaseFirestore.instance
        .collection('UserInfo')
        .doc(AuthService().currentUser!.uid)
        .get();
    String sellerName = result.get('name');
    String sellerContact = result.get('contact').toString();
    setState(() => {name = sellerName, contact = sellerContact});
  }

  //When details are retrieved, update the profile page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  //backdrop image
                  Image(
                    image: const NetworkImage(
                      //change to shop image next time
                      "https://static.vecteezy.com/system/resources/previews/005/489/284/non_2x/beautiful-purple-color-gradient-background-free-vector.jpg"),
                    height: MediaQuery.of(context).size.height / 5,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),

                  //profile picture
                  const Positioned(
                    bottom: -70,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 65,
                        backgroundImage: NetworkImage(
                            "https://data.whicdn.com/images/274337232/original.jpg"),
                      ),
                    ),
                  ),
                ],
              ),

              emptyBox(70),

              //display name
              editing
                  ? ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 25, right: 25),
                      title: const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text("Name"),
                      ),
                      subtitle: TextFormField(
                        initialValue: name,
                        onChanged: (val) => setState(() => name = val),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Cannot be empty';
                          }
                          return null;
                        },
                      ))
                  : ListTile(
                      contentPadding: const EdgeInsets.only(left: 25),
                      title: const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text("Name"),
                      ),
                      subtitle: futureText(
                          context,
                          userInformation,
                          _auth.currentUser!.uid,
                          'name') //get user name from database
                      ),

              //display phone number
              editing
                  ? ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 25, right: 25),
                      title: const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text("Phone Number"),
                      ),
                      subtitle: TextFormField(
                        initialValue: contact,
                        onChanged: (val) => setState(() => contact = val),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Cannot be empty';
                          } else if (val.length < 8) {
                            return 'Enter a valid phone number';
                          }
                          try {
                            int.parse(val);
                            return null;
                          } catch (e) {
                            return 'Enter only numbers';
                          }
                        },
                      ))
                  : ListTile(
                      contentPadding: const EdgeInsets.only(left: 25),
                      title: const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text("Phone Number"),
                      ),
                      subtitle: futureText(
                          context,
                          userInformation,
                          _auth.currentUser!.uid,
                          'contact') //get number from database
                      ),

              //display email
              ListTile(
                contentPadding: const EdgeInsets.only(left: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Email Address"),
                ),
                subtitle: futureText(context, userInformation,
                    _auth.currentUser!.uid, 'email'), //get email from database
              ),

              //display role
              ListTile(
                contentPadding: const EdgeInsets.only(left: 25),
                title: const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("Role"),
                ),
                subtitle: futureText(
                    context, userInformation, _auth.currentUser!.uid, 'role'),
              ),

              emptyBox(20),

              //edit profile button
              editing
                  ? bigButton('Save Changes', () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => editing = false);
                        _auth.updateDetails(name, contact);
                        successFlushBar(context, "Changes saved", true);
                      }
                    })
                  : bigButton("Edit Profile", () {
                      setState(() => editing = true);
                    }),

              emptyBox(15),

              //delete account button
              editing
                  ? bigButton('Delete Account', 
                  () => confirmationPopUp(
                    context, 
                    "Are you sure you want to delete your account? If your account is linked to a shop, your shop will not be deleted",
                    () async {
                      removeSellerFromShop();
                      _auth.deleteUser()
                      .then((value) => _auth.signOut())
                      .then(
                        (value) => redFlushBar(context, "Account deleted successfully", true));
                    }
                  ))
                  : emptyBox(1),
              
              emptyBox(10)                   
            ],
          ),
        ),
      ),
    );
  }

  Future removeSellerFromShop() async {
    Shop? currShop = await getSellerShop();
    if (currShop == null) {
      return null;
    }
    return shops
      .doc(currShop.uid)
      .update({
        'sellerID': FieldValue.delete(),
      });
  }
}
