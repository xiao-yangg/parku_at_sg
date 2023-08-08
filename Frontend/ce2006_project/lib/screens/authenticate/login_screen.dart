import 'package:ce2006_project/components/custom_material_button.dart';
import 'package:ce2006_project/components/text_box.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/screens/authenticate/register_screen.dart';
import 'package:ce2006_project/screens/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// This is the LoginScreen class also known as Login Page
/// Attributes:
/// emailController - controller for email textbox
/// passwordController - controller for password textbox
/// _auth - instance of Firebase Authentication
/// loggedInUser - current logged in user base on Firebase Authentication
/// errorMessage - display error message if any
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  User? loggedInUser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    emailController.value =
        emailController.value.copyWith(text: loggedInUser?.email);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kLightColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (MediaQuery.of(context).viewInsets.bottom == 0.0)
                SizedBox(
                  child: Image.asset('assets/images/logo_dark.png'),
                  height: 0.26 * MediaQuery.of(context).size.height,
                ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Text(
                      'Welcome back!',
                      style: kAppTitleStyle.copyWith(
                          fontSize: 25, color: kDarkColor),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 0.04 * MediaQuery.of(context).size.height,
                    ),
                    TextBox(
                      controller: emailController,
                      text: 'Email',
                      register: false,
                      color: kDarkColor,
                      isPassword: false,
                    ),
                    TextBox(
                      controller: passwordController,
                      text: 'Password',
                      register: false,
                      color: kDarkColor,
                      isPassword: true,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(30.0),
                decoration: const BoxDecoration(
                  color: kDarkColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: CustomMaterialButton(
                        function: loginUser,
                        text: 'LOG IN',
                        kPrimaryColor: kDarkColor,
                        kSecondaryColor: kLightColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'No account? Register now!',
                        style: TextStyle(
                          color: kLightColor,
                          fontSize: 15.0,
                          decoration: TextDecoration.underline,
                        ),
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

  /// This function login user
  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          // show logging in
          context: context,
          barrierColor: const Color(0x00ffffff), // transparent
          barrierDismissible: false,
          builder: (context) => Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: 0.35 * MediaQuery.of(context).size.height,
                left: 0.2 * MediaQuery.of(context).size.width,
                right: 0.2 * MediaQuery.of(context).size.width,
              ),
              child: const SizedBox(
                child: LinearProgressIndicator(
                  color: kDarkColor,
                  backgroundColor: kLightColor,
                  minHeight: 8,
                ),
              ),
            ),
          ),
        );

        final user = await _auth.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

        Navigator.pop(context); // end of login

        if (user != null) {
          // go to Loading Page
          Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const LoadingScreen(),
              ),
              (Route<dynamic> route) => false);
        }
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "user-not-found":
            errorMessage = "Invalid credentials";
            break;
          case "wrong-password":
            errorMessage = "Invalid credentials";
            break;
          default:
            errorMessage = "Login Failed";
        }
        Navigator.pop(context); // end of login

        Fluttertoast.showToast(msg: errorMessage!);
      }
    }
  }
}
