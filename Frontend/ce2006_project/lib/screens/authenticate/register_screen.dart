import 'package:ce2006_project/components/custom_material_button.dart';
import 'package:ce2006_project/components/text_box.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/screens/authenticate/login_screen.dart';
import 'package:ce2006_project/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// This is the RegisterScreen class also known as Register Page
/// Attributes:
/// emailController - controller for email textbox
/// passwordController - controller for password textbox
/// _auth - instance of Firebase Authentication
/// _firestore - instance of Firestore
/// errorMessage - display error message if any
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  static const String id = 'register_screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kDarkColor,
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
                  child: Image.asset('assets/images/logo_light.png'),
                  height: 0.26 * MediaQuery.of(context).size.height,
                ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Text(
                      'Hello there!',
                      style: kAppTitleStyle.copyWith(
                          fontSize: 25, color: kLightColor),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 0.04 * MediaQuery.of(context).size.height,
                    ),
                    TextBox(
                      controller: emailController,
                      text: 'Email',
                      register: false,
                      color: kLightColor,
                      isPassword: false,
                    ),
                    TextBox(
                      controller: passwordController,
                      text: 'Password',
                      register: false,
                      color: kLightColor,
                      isPassword: true,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(30.0),
                decoration: const BoxDecoration(
                  color: kLightColor,
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
                        function: registerUser,
                        text: 'CREATE ACCOUNT',
                        kPrimaryColor: kLightColor,
                        kSecondaryColor: kDarkColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Already have account? Sign In!',
                        style: TextStyle(
                          color: kDarkColor,
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

  /// This function register user
  void registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          // show registering
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
                  color: kLightColor,
                  backgroundColor: kDarkColor,
                  minHeight: 8,
                ),
              ),
            ),
          ),
        );

        final newUser = await _auth.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

        Navigator.pop(context); // end of register

        if (newUser != null) {
          User? loggedInUser = _auth.currentUser;

          String? uid;
          uid = loggedInUser?.uid;

          _firestore.collection(uid!).add({
            'id': loggedInUser!.uid,
            'darkModeStatus': false,
            'adStatus': false,
            'recents': [],
            'bookmarks': [],
          });

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
          case "email-already-in-use":
            errorMessage = "Email already taken";
            break;
          case "invalid-email":
            errorMessage = "Invalid email";
            break;
          default:
            errorMessage = "Register Failed";
        }
        Navigator.pop(context); // end of register

        Fluttertoast.showToast(msg: errorMessage!);
      }
    }
  }
}
