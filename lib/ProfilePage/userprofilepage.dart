import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import 'package:foodies/reusablewidgets.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final AuthService _auth = AuthService();
  final CollectionReference userInformation =
      FirebaseFirestore.instance.collection('UserInfo');

  //When details are retrieved, update the profile page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                //backdrop image
                Image(
                  image: const NetworkImage(
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
                          "https://pbs.twimg.com/media/EdxsmDKWAAI2h5v.jpg"),
                    ),
                  ),
                ),
              ],
            ),

            emptyBox(70),

            //display name
            ListTile(
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
            ListTile(
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
            bigButton("Edit Profile", () {})
          ],
        ),
      ),
    );
  }
}
