import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import '../loading.dart';
import 'package:bordered_text/bordered_text.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // ignore: unused_field
  final AuthService _auth = AuthService();
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: TextButton.icon(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                /*label: const Text(
              'Back',
              style: TextStyle(color: Colors.black),
            ),*/
                onPressed: () {
                  Navigator.pop(context);
                },
                label: Container(),
              ),
            ),
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
                        const SizedBox(
                          height: 125.0,
                        ),
                        Center(
                          child: BorderedText(
                            strokeColor: Colors.blue,
                            strokeWidth: 2.0,
                            child: const Text(
                              //sign up
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.transparent,
                                fontSize: 55.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        Padding(
                          //enter name
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Name',
                              hintText: 'Enter your name',
                              prefixIcon: Icon(Icons.account_circle_rounded),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Cannot be empty';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() => name = val);
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                          //enter contact number
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Contact Number',
                              hintText: 'Enter a valid phone number',
                              prefixIcon: Icon(Icons.local_phone),
                            ),
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
                            onChanged: (val) {
                              setState(() => phone = val);
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                          //enter email
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                              hintText: 'Enter a valid email',
                              prefixIcon: Icon(Icons.email_outlined),
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
                        const SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                          //enter password
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                              hintText: 'Choose your password',
                              prefixIcon: Icon(Icons.lock_outlined),
                            ),
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Cannot be empty';
                              } else if (val.length < 6) {
                                return 'Password needs to be at least 6 characters long';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                          //choose user type
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                        const SizedBox(
                          height: 40.0,
                        ),
                        Container(
                          //create account
                          height: 60.0,
                          width: 250.0,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result = await _auth.register(
                                    name, phone, email, type, password);

                                if (result == null) {
                                  setState(() => error = 'Invalid email');
                                } else {
                                  setState(() => error = 'Success!');
                                  _auth.signOut();
                                }
                                setState(() => loading = false);
                              } else {
                                setState(() => error = '');
                              }
                            },
                            child: const Text(
                              'Create Account',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
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
