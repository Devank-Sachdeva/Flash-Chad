import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashchad/screens/welcome_screen.dart';
import 'package:flashchad/screens/login_screen.dart';
import 'package:flashchad/screens/registration_screen.dart';
import 'package:flashchad/screens/chat_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF212121),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen()
      },
    );
  }
}
