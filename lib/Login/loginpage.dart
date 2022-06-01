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
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                //background
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
                        
                        //logo
                        Padding(
                          padding: const EdgeInsets.only(top: 80.0),
                          child: Center(
                            child: Container(
                              color: Colors.transparent,
                              width: 400,
                              height: 300,
                              child: Image.asset('assets/images/logo3.png'),
                            ),
                          ),
                        ),
                        
                        //enter email
                        inputText("Email", "Enter a valid email", const Icon(Icons.email_outlined), 
                        (val) {
                          if (val == null || val.isEmpty) {
                            return 'Cannot be empty';
                          }
                          return null;
                        }, 
                        (val) => setState(() => email = val)),
                        
                        emptyBox(15.0),

                        //enter password
                        inputText("Password", "Choose your password", const Icon(Icons.lock_outlined), 
                        (val) {
                          if (val == null || val.isEmpty) {
                            return 'Cannot be empty';
                          } 
                          return null;
                        }, 
                        (val) => setState(() => password = val)),

                        emptyBox(5.0),

                        //error message (if any)
                        Text(
                          error,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 15.0),
                        ),

                        //forgot password button
                        TextButton(
                          onPressed: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) => const ForgotPassword())),
                          child: const Text(
                            "Forgot Password",
                            style:
                                TextStyle(color: Colors.blue, fontSize: 15.0),
                          ),
                        ),

                        //login button
                        bigButton("Login", 
                          () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => loading = true);
                              dynamic result = await _auth.signIn(email, password);

                              if (result == null) {
                                setState(() {
                                  loading = false;
                                  error = 'Invalid email or password';
                                });
                              }
                            }
                          }
                        ),

                        emptyBox(10.0),

                        //sign in as guest button
                        bigButton("Sign in as Guest", 
                          () async {
                            setState(() => loading = true);
                            await _auth.signInAnonymous();
                          }
                        ),
                        
                        emptyBox(50.0),

                        //create account button
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) => const CreateAccountPage())),
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
              ],
            ),
          );
  }
}
