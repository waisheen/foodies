import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../loading.dart';
import '../reusablewidgets.dart';
import 'all.dart';
import '../Services/all.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  //Variable states
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: Stack(children: [
              //background
              /*Container(
                constraints: const BoxConstraints.expand(),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/images/bg1.png'),
                  fit: BoxFit.cover,
                )),
              ),*/
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      //logo
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Center(
                          child: Container(
                            color: Colors.transparent,
                            width: 300,
                            height: 300,
                            child: Image.asset('assets/images/logo5.png'),
                          ),
                        ),
                      ),

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
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                labelText: "Password",
                                hintText: "Enter your password",
                                prefixIcon: const Icon(Icons.lock_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Cannot be empty';
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (val) =>
                                  setState(() => password = val),
                              obscureText: true)),

                      emptyBox(5.0),

                      //error message (if any)
                      // Text(
                      //   error,
                      //   style:
                      //       const TextStyle(color: Colors.red, fontSize: 15.0),
                      // ),

                      //forgot password button
                      TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPassword())),
                        child: const Text(
                          "Forgot Password",
                          style: TextStyle(color: Colors.blue, fontSize: 15.0),
                        ),
                      ),

                      //login button
                      bigButton("Login", () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                          dynamic result = await _auth.signIn(email, password);

                          if (result == null) {
                            setState(() {
                              loading = false;
                              error = 'Invalid email or password';
                              redFlushBar(context, error, true);
                            });
                          } else {
                            //not working
                            var user = await FirebaseFirestore.instance
                              .collection('UserInfo')
                              .doc(AuthService().currentUser!.uid)
                              .get();
                            String name = user.get("name");
                            
                            setState(() => successFlushBar(context, "Welcome $name!", false));
                          }
                        }
                      }),

                      emptyBox(10.0),

                      //sign in as guest button
                      bigButton("Sign in as Guest", () async {
                        await _auth.signInAnonymous();
                        setState(() {
                          loading = true;
                          successFlushBar(context, "Welcome!", false);
                        });
                      }),

                      emptyBox(50.0),

                      //create account button
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAccountPage())),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Text(
                              'New User? ',
                            ),
                            Text('Create Account',
                                style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]));
  }
}
