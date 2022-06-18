import 'package:flutter/material.dart';
import 'package:foodies/reusablewidgets.dart';
import '../Models/shop.dart';
import '../loading.dart';
import 'package:bordered_text/bordered_text.dart';

class CreatePromotionPage extends StatefulWidget {
  const CreatePromotionPage({Key? key, required this.shop}) : super(key: key);
  final Shop shop;

  @override
  State<CreatePromotionPage> createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends State<CreatePromotionPage> {
  final _formKey = GlobalKey<FormState>();

  //Variable states
  String name = '';
  String phone = '';
  String email = '';
  String password = '';
  String type = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: backButton(context),
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Container(
                  constraints: const BoxConstraints.expand(),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/images/bg1.png'),
                    fit: BoxFit.cover,
                  )),
                ),
                SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        emptyBox(125.0),

                        //sign up text
                        Center(
                          child: BorderedText(
                            strokeColor: Colors.blue,
                            strokeWidth: 2.0,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.transparent,
                                fontSize: 55.0,
                              ),
                            ),
                          ),
                        ),

                        emptyBox(25.0),

                        //enter name
                        inputText("Name", "Enter your name",
                            const Icon(Icons.account_circle_rounded), (val) {
                          if (val == null || val.isEmpty) {
                            return 'Cannot be empty';
                          }
                          return null;
                        }, (val) => setState(() => name = val)),

                        emptyBox(15.0),

                        //enter phone number
                        inputText(
                            "Contact Number",
                            "Enter a valid phone number",
                            const Icon(Icons.local_phone), (val) {
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
                        }, (val) => setState(() => phone = val)),

                        emptyBox(15.0),

                        //enter email
                        inputText("Email", "Enter a valid email",
                            const Icon(Icons.email_outlined), (val) {
                          if (val == null || val.isEmpty) {
                            return 'Cannot be empty';
                          }
                          return null;
                        }, (val) => setState(() => email = val)),

                        emptyBox(15.0),

                        //enter password
                        inputObscuredText("Password", "Choose your password",
                            const Icon(Icons.lock_outlined), (val) {
                          if (val == null || val.isEmpty) {
                            return 'Cannot be empty';
                          } else if (val.length < 6) {
                            return 'Password needs to be at least 6 characters long';
                          }
                          return null;
                        }, (val) => setState(() => password = val)),

                        emptyBox(15.0),

                        //choose user type
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: DropdownButtonFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.analytics_rounded)),
                            hint: const Text('Choose your account type'),
                            items: const <String>['User', 'Seller']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            validator: (val) {
                              if (val == null ||
                                  (val != 'User' && val != 'Seller')) {
                                return 'Choose an account type';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() => type = val.toString());
                            },
                          ),
                        ),

                        emptyBox(25.0),

                        //create account  button
                        bigButton("Create Account", () async {
                          if (_formKey.currentState!.validate()) {
                            // setState(() => loading = true);
                            // dynamic result = await _auth.register(
                            //     name, phone, email, type, password);

                            // if (result == null) {
                            //   setState(() => error = 'Invalid email');
                            // } else {
                            //   setState(() => error = 'Success!');
                            //   _auth.signOut();
                            // }
                            // setState(() => loading = false);
                          }
                        }),

                        emptyBox(10.0),

                        Text(
                          error,
                          style: TextStyle(
                              color: error == 'Success!'
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
