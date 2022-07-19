import 'package:awesome_select/awesome_select.dart';
import 'package:flutter/material.dart';
import 'package:foodies/Services/all.dart';
import 'package:foodies/reusablewidgets.dart';
import '../loading.dart';
import 'package:bordered_text/bordered_text.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key, required this.noSellerShops})
      : super(key: key);
  final List<String> noSellerShops;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
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
  bool isSeller = false;
  List<String> _selectedOptions = [];

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
                /*Container(
                  constraints: const BoxConstraints.expand(),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/images/bg1.png'),
                    fit: BoxFit.cover,
                  )),
                ),*/
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        emptyBox(125.0),

                        //sign up text
                        Center(
                          child: BorderedText(
                            strokeColor: themeColour,
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
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                prefixIcon:
                                    const Icon(Icons.analytics_rounded)),
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
                              setState(() {
                                type = val.toString();
                                if (val.toString() == 'Seller') {
                                  isSeller = true;
                                } else {
                                  isSeller = false;
                                }
                              });
                            },
                          ),
                        ),

                        emptyBox(10.0),

                        //For sellers to pick their shops
                        !isSeller
                            ? emptyBox(1.0)
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, left: 30, right: 30),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey)),
                                  child: SmartSelect<String>.multiple(
                                      title: '',
                                      placeholder: 'Choose Shops',
                                      selectedValue: _selectedOptions,
                                      modalHeaderStyle: S2ModalHeaderStyle(
                                          backgroundColor: themeColour),
                                      onChange: (selected) {
                                        setState(() => _selectedOptions =
                                            selected!.value == null
                                                ? List.empty(growable: true)
                                                : selected.value!);
                                      },
                                      choiceItems: widget.noSellerShops
                                          .map((string) => S2Choice<String>(
                                              title: string, value: string))
                                          .toList(),
                                      choiceType: S2ChoiceType.switches,
                                      choiceActiveStyle: S2ChoiceStyle(
                                        color: themeColour,
                                      ),
                                      modalFilter: true,
                                      modalConfirm: true,
                                      modalType: S2ModalType.fullPage,
                                      tileBuilder: (context, state) {
                                        return S2Tile.fromState(
                                          state,
                                          trailing: const Icon(
                                              Icons.add_circle_outline),
                                          leading: const Icon(
                                            Icons.house,
                                            color: Colors.grey,
                                          ),
                                        );
                                      }),
                                ),
                              ),

                        emptyBox(25.0),

                        //create account  button
                        bigButton("Create Account", () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => loading = true);
                            dynamic result = isSeller
                                ? await _auth.registerSeller(name, phone, email,
                                    type, password, _selectedOptions)
                                : await _auth.register(
                                    name, phone, email, type, password);

                            if (result == null) {
                              setState(() {
                                error = 'Invalid email';
                                redFlushBar(context, error, true);
                              });
                            } else {
                              setState(() {
                                error = 'Success!';
                                Navigator.pop(context);
                                _auth.signOut();
                                !isSeller
                                    ? successFlushBar(context,
                                        "Account created successfully", true)
                                    : successFlushBar(
                                        context,
                                        "Account created successfully, await approval for shops",
                                        true);
                              });
                            }
                            setState(() => loading = false);
                          }
                        }),

                        emptyBox(30.0),

                        // Text(
                        //   error,
                        //   style: TextStyle(
                        //       color: error == 'Success!'
                        //           ? Colors.green
                        //           : Colors.red,
                        //       fontSize: 15.0),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
