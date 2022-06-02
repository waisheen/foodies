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
            const ListTile(
              contentPadding: EdgeInsets.only(left: 25),
              title: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Name"),
              ),
              subtitle: Text("get user name",
                  style: TextStyle(fontSize: 16)), //get user name from database
            ),

            //display phone number
            const ListTile(
              contentPadding: EdgeInsets.only(left: 25),
              title: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Phone Number"),
              ),
              subtitle: Text("get user phone number",
                  style: TextStyle(fontSize: 16)), //get number from database
            ),

            //display email
            const ListTile(
              contentPadding: EdgeInsets.only(left: 25),
              title: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Email Address"),
              ),
              subtitle: Text("get user email",
                  style: TextStyle(fontSize: 16)), //get email from database
            ),

            //display role
            const ListTile(
              contentPadding: EdgeInsets.only(left: 25),
              title: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text("Role"),
              ),
              subtitle: Text("User", style: TextStyle(fontSize: 16)),
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
