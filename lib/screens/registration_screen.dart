import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flashchad/components/roundButton.dart';
import 'package:flashchad/constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = '/RegistrationScreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool showSpinner = false;
  bool emailActive = false;
  bool passActive = false;
  bool passLooking = false;
  bool emailLooking = false;
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  String? get _errorPassText {
    final text = _passController.value.text;
    if (passActive) {
      if (text.isEmpty) {
        passLooking = false;
        return 'Can\'t be empty';
      }
      if (text.length < 7) {
        passLooking = false;
        return 'Password Must Be Longer than 6 characters';
      }
      passLooking = true;
      return null;
    } else {
      return null;
    }
  }

  String? get _errorEmailText {
    final text = _emailController.value.text;
    if (emailActive) {
      if (text.isEmpty) {
        emailLooking = false;
        return 'Can\'t be empty';
      }
      if (!text.contains('@')) {
        emailLooking = false;
        return 'Invalid Email address';
      }
      emailLooking = true;
      return null;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget verify() {
    if (email == null || password == null) {
      return AlertDialog(
        title: Text('Please fill the details properly'),
        content: Text('Chutiya hai kya'),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        // backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                onTap: () => emailActive = true,
                controller: _emailController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => setState(() => email = value),
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                  errorText: _errorEmailText,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                onTap: () => passActive = true,
                controller: _passController,
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) => setState(() => password = value),
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                  errorText: _errorPassText,
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundButton(
                colour: Colors.blueAccent,
                titleText: 'Register',
                onPressFunction: (emailLooking && passLooking)
                    ? () async {
                        setState(() {
                          showSpinner = true;
                        });
                        // verify();
                        try {
                          final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                          final prefs = await SharedPreferences.getInstance();
                          String userEmail = newUser.user?.email ?? ' ';
                          await prefs.setString('LoggedInUser', userEmail);

                          Navigator.pushNamed(context, ChatScreen.id);
                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          print('error aayi bsdk');
                          print(e);
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
