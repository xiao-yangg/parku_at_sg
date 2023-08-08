import 'package:ce2006_project/components/custom_material_button.dart';
import 'package:ce2006_project/components/text_box.dart';
import 'package:ce2006_project/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// This is the EditScreen class also known as Edit Page
/// Attributes:
/// particulars - particulars to change
/// kPrimaryColor - primary color
/// kSecondaryColor - secondary color
/// emailController - controller for email textbox
/// passwordController - controller for password textbox
/// loggedInUser - current logged in user base on Firebase Authentication
class EditScreen extends StatefulWidget {
  final String particulars;
  final Color kPrimaryColor;
  final Color kSecondaryColor;

  const EditScreen({
    Key? key,
    required this.particulars,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final TextEditingController emailController1 = TextEditingController();
  final TextEditingController emailController2 = TextEditingController();
  final TextEditingController passwordController1 = TextEditingController();
  final TextEditingController passwordController2 = TextEditingController();

  User? loggedInUser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.kPrimaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: widget.kSecondaryColor,
        ),
        backgroundColor: widget.kPrimaryColor,
        elevation: 0,
        title: Text(
          'CHANGE ${widget.particulars}',
          style: kAppTitleStyle.copyWith(
              fontSize: 20, color: widget.kSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  if (widget.particulars == 'Password')
                    TextBox(
                      controller: emailController2,
                      text: 'Current Email',
                      register: false,
                      color: widget.kSecondaryColor,
                      isPassword: false,
                    ),
                  TextBox(
                    controller: (widget.particulars == 'Email')
                        ? emailController1
                        : passwordController1,
                    text: 'Current ${widget.particulars}',
                    register: false,
                    color: widget.kSecondaryColor,
                    isPassword: (widget.particulars == 'Email') ? false : true,
                  ),
                  TextBox(
                    controller: (widget.particulars == 'Email')
                        ? emailController2
                        : passwordController2,
                    text: 'New ${widget.particulars}',
                    register: false,
                    color: widget.kSecondaryColor,
                    isPassword: (widget.particulars == 'Email') ? false : true,
                  ),
                  if (widget.particulars == 'Email')
                    TextBox(
                      controller: passwordController2,
                      text: 'Current Password',
                      register: false,
                      color: widget.kSecondaryColor,
                      isPassword: true,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: CustomMaterialButton(
                function: changeParticulars,
                text: 'SUBMIT',
                kPrimaryColor: widget.kPrimaryColor,
                kSecondaryColor: widget.kSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// This function is to change user particulars
  void changeParticulars() async {
    if (_formKey.currentState!.validate()) {
      if (widget.particulars == 'Email') {
        changeEmail(
          emailController1.text,
          passwordController2.text,
          emailController2.text,
        );
      } else {
        changePassword(
          emailController2.text,
          passwordController1.text,
          passwordController2.text,
        );
      }

      Navigator.of(context).pop(context);
    }
  }

  /// This function is to change user email on Firebase Authentication
  void changeEmail(
      String currentEmail, String currentPassword, String newEmail) async {
    String? errorMessage;

    final cred = EmailAuthProvider.credential(
        email: currentEmail, password: currentPassword);

    loggedInUser?.reauthenticateWithCredential(cred).then((_) {
      loggedInUser?.updatePassword(newEmail).then((__) {
        //Success, do something
        errorMessage = "Email changed successfully";
      }).catchError((error) {
        //Error, show something
        errorMessage = "Error changing email";
      });
    }).catchError((error) {
      errorMessage = "Invalid credentials";
    });
    Fluttertoast.showToast(msg: errorMessage!);
  }

  /// This function is to change user password on Firebase Authentication
  void changePassword(
      String currentEmail, String currentPassword, String newPassword) async {
    String? errorMessage;

    final cred = EmailAuthProvider.credential(
        email: currentEmail, password: currentPassword);

    loggedInUser?.reauthenticateWithCredential(cred).then((_) {
      loggedInUser?.updatePassword(newPassword).then((__) {
        //Success, do something
        errorMessage = "Password changed successfully";
      }).catchError((error) {
        //Error, show something
        errorMessage = "Error changing password";
      });
    }).catchError((error) {
      errorMessage = "Invalid credentials";
    });
    Fluttertoast.showToast(msg: errorMessage!);
  }
}
