import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flashchad/screens/chat_screen.dart';
import 'package:flashchad/screens/login_screen.dart';
import 'package:flashchad/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashchad/components/roundButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = '/WelcomeScreen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late Animation animation;
  late AnimationController controller;

  Future<void> checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? str = prefs.getString('LoggedInUser');
    print(str);

    if (str != null && str != 'signed out' && mounted) {
      Navigator.pushNamed(context, ChatScreen.id);
    }
  }

  @override
  void initState() {
    super.initState();
    checkUser();
    AnimationController controller = AnimationController(vsync: this, duration: Duration(seconds: 3));
    animation = ColorTween(begin: Colors.white38, end: Color(0xFF212121)).animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
      // print(animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 60.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                AnimatedTextKit(
                  // repeatForever: true,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Flash Chad',
                      textStyle: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundButton(
              colour: Colors.lightBlueAccent,
              titleText: 'Log in',
              onPressFunction: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundButton(
              colour: Colors.blueAccent,
              titleText: 'Register',
              onPressFunction: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
