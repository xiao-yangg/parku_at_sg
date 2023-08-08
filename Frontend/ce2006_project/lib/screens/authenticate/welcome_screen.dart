import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:ce2006_project/components/custom_material_button.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/screens/authenticate/login_screen.dart';
import 'package:ce2006_project/screens/authenticate/register_screen.dart';
import 'package:flutter/material.dart';

/// This is the WelcomeScreen class also known as Welcome Page
/// Attributes: none
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    controller.forward();

    animation =
        ColorTween(begin: kLightColor, end: kLightColor).animate(controller);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              child: Image.asset('assets/images/logo_light.png'),
              height: 250.0,
            ),
            const SizedBox(
              height: 15.0,
            ),
            AnimatedTextKit(
              totalRepeatCount: 1,
              animatedTexts: [
                TyperAnimatedText(
                  kAppName,
                  textStyle:
                      kAppTitleStyle.copyWith(fontSize: 40, color: kLightColor),
                  textAlign: TextAlign.center,
                  speed: const Duration(milliseconds: 200),
                ),
              ],
            ),
            const SizedBox(
              height: 50.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: CustomMaterialButton(
                function: () {
                  // go to Login Page
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginScreen(),
                    ),
                  );
                },
                text: 'LOG IN',
                kPrimaryColor: kDarkColor,
                kSecondaryColor: kLightColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: CustomMaterialButton(
                function: () {
                  // go to Register Page
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RegisterScreen(),
                    ),
                  );
                },
                text: 'REGISTER',
                kPrimaryColor: kDarkColor,
                kSecondaryColor: kLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
