import 'package:flutter/material.dart';
import '../loading.dart';
import 'all.dart';
import '../Services/all.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

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
                        Padding(
                          //logo
                          padding: const EdgeInsets.only(top: 80.0),
                          child: Center(
                            child: SizedBox(
                              width: 400,
                              height: 300,
                              child: Image.asset('assets/images/logo.png'),
                            ),
                          ),
                        ),
                        Padding(
                          //email
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: 'Enter your email',
                            ),
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                          ),
                        ),
                        Padding(
                          //password
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15.0, bottom: 0.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outlined),
                              hintText: 'Enter your password',
                            ),
                            obscureText: true,
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          error,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 15.0),
                        ),
                        TextButton(
                          //forgot password
                          onPressed: () {
                            //Function for forgot password button
                          },
                          child: const Text(
                            "Forgot Password",
                            style:
                                TextStyle(color: Colors.blue, fontSize: 15.0),
                          ),
                        ),
                        Container(
                          //login
                          height: 50.0,
                          width: 250.0,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result =
                                    await _auth.signIn(email, password);

                                if (result == null) {
                                  setState(() {
                                    loading = false;
                                    error = 'Invalid email or password';
                                  });
                                }
                              }
                            },
                            child: const Text(
                              'Login',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          //sign in as guest
                          height: 50.0,
                          width: 250.0,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              setState(() => loading = true);
                              await _auth.signInAnonymous();
                            },
                            child: const Text(
                              'Sign in as Guest',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50.0,
                        ),
                        GestureDetector(
                          //new user? create account
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateAccountPage()));
                          },
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
