import 'package:flutter/material.dart';
import 'package:flashchad/components/roundButton.dart';
import 'package:flashchad/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashchad/components/errorHandle.dart';

class LoginScreen extends StatefulWidget {
  static const String id = '/LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ErrorHandler handle = ErrorHandler();
  final _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool showSpinner = false;
  bool emailActive = false;
  bool passActive = false;
  bool passLooking = false;
  bool emailLooking = false;
  late String email;
  late String password;
  String? newError;

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

  Widget displayErrorText() {
    if (newError == null) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          newError!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            wordSpacing: 2.0,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
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
              displayErrorText(),
              TextField(
                onTap: () => emailActive = true,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
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
                obscureText: true,
                onTap: () => passActive = true,
                controller: _passController,
                textAlign: TextAlign.center,
                onChanged: (value) => setState(() {
                  password = value;
                  print(value);
                }),
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                  errorText: _errorPassText,
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundButton(
                colour: Colors.lightBlueAccent,
                titleText: 'Log in',
                onPressFunction: (emailLooking && passLooking)
                    ? () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          final goodUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
                          final prefs = await SharedPreferences.getInstance();
                          String userEmail = goodUser.user?.email ?? ' ';
                          await prefs.setString('LoggedInUser', userEmail);
                          if (mounted){Navigator.pushNamed(context, ChatScreen.id);}
                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          print(e);
                          newError = handle.getMessageFromErrorCode(e);
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
