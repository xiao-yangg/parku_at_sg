import 'package:ce2006_project/screens/authenticate/login_screen.dart';
import 'package:ce2006_project/screens/authenticate/register_screen.dart';
import 'package:ce2006_project/screens/authenticate/welcome_screen.dart';
import 'package:ce2006_project/screens/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// This is the main function to initialize Firebase and MobileAds before MyApp class
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

/// This is the MyApp class used in initializing ParkU@SG application
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: StartScreen.id,
      routes: {
        StartScreen.id: (context) => const StartScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegisterScreen.id: (context) => const RegisterScreen(),
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        // LoadingScreen.id: (context) => const LoadingScreen(), // testing
      },
    );
  }
}
