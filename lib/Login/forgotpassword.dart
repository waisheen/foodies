import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Login/all.dart';
import 'package:foodies/Services/auth.dart';
import 'package:foodies/loading.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  //variable states
  String email = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: TextButton.icon(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
                label: Container(),
              ),
            ),
            backgroundColor: Colors.transparent,
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
                        const SizedBox(
                          height: 15,
                        ),
                        const Center(
                          child: Text(
                            "Reset Password",
                            style:
                                TextStyle(color: Colors.black, fontSize: 25.0),
                          ),
                        ),
                        const SizedBox(
                          height: 100,
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
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Cannot be empty';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                          ),
                        ),
                        Text(
                          error,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 15.0),
                        ),
                        const SizedBox(height: 30.0),
                        Container(
                          //reset password button
                          height: 50.0,
                          width: 250.0,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result = _auth.resetPassword(email);
                                
                                if (result == null) {
                                  setState(() => error = 'Invalid email');
                                } else {
                                  setState(() => error = 'Check your email to reset password');
                                }
                                setState(() => loading = false);
                              }
                            },
                            child: const Text(
                              'Reset Password',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
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
