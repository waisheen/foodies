import 'package:flutter/material.dart';
import 'package:foodies/Services/auth.dart';
import 'package:foodies/loading.dart';

import '../reusablewidgets.dart';

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
            extendBodyBehindAppBar: false,
            appBar: backButton(context),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    //reset password text
                    const Center(
                      child: Text(
                        "Reset Password",
                        style:
                            TextStyle(color: Colors.black, fontSize: 25.0),
                      ),
                    ),

                    emptyBox(20.0),

                    //enter email
                    inputText("Email", "Enter a valid email",
                        const Icon(Icons.email_outlined), (val) {
                      if (val == null || val.isEmpty) {
                        return 'Cannot be empty';
                      }
                      return null;
                    }, (val) => setState(() => email = val)),

                    //error message (if any)
                    Text(
                      error,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 15.0),
                    ),

                    emptyBox(10.0),

                    //reset password button
                    bigButton("Reset Password", () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => loading = true);
                        dynamic result = await _auth.resetPassword(email);

                        if (result == "invalid-email") {
                          setState(() => error = 'Invalid email');
                        } else if (result == "user-not-found") {
                          setState(() => error = "No existing account found");
                        } else {
                          setState(() => error = "Check your inbox/spam inbox to reset password");
                        }
                        setState(() => loading = false);
                      }
                    })
                  ],
                ),
              ),
            )
          );
  }
}
