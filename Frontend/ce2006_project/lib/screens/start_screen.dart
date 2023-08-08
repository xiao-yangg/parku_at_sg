import 'dart:async';

import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/screens/authenticate/welcome_screen.dart';
import 'package:ce2006_project/screens/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// This is the StartScreen class also known as Start Page
/// Attributes:
/// loggedInUser - current logged in user base on Firebase Authentication
class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  static const String id = 'start_screen';

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  User? loggedInUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 4), () {
      // bypass if user already authenticated
      if (loggedInUser != null) {
        // go to Loading Page
        Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoadingScreen(),
            ),
            (Route<dynamic> route) => false);
      } else {
        // go to Welcome Page
        Navigator.of(context).pushNamedAndRemoveUntil(
            WelcomeScreen.id, (Route<dynamic> route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(
                        10.0,
                      ),
                      constraints: const BoxConstraints(
                        maxHeight: 250.0,
                        maxWidth: 250.0,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                        child: Image.asset('assets/images/start_logo.png'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
