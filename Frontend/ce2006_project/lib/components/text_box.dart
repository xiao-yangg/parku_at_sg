import 'package:ce2006_project/constants.dart';
import 'package:flutter/material.dart';

/// This is the NumericStepButton class used in SelectCarpark widget
/// Attributes:
/// controller - TextFormField controller for this particular textbox
/// text - display text on TextFormField
/// register - if is used for register
/// color - color
/// isPassword - if is used for password fill
class TextBox extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final bool register;
  final Color color;
  final bool isPassword;

  @override
  const TextBox({
    Key? key,
    required this.controller,
    required this.text,
    required this.register,
    required this.color,
    required this.isPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 15.0,
              ),
            ),
          ),
          TextFormField(
            obscureText: isPassword,
            keyboardType: TextInputType.name,
            textAlign: TextAlign.start,
            style: const TextStyle(color: kDarkColor),
            controller: controller,
            validator: (value) {
              return validateText(value!);
            },
            onSaved: (value) {
              controller.text = value!;
            },
            decoration: kTextFieldDecoration.copyWith(fillColor: kLightColor),
          ),
        ],
      ),
    );
  }

  /// This function is used to validate text in TextFormField
  String? validateText(String value) {
    if (!isPassword) {
      if (value!.isEmpty) {
        return ("Please enter email");
      }
      //reg expression for email validation
      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
        return ("Invalid email");
      }
    } else if (isPassword) {
      RegExp regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
      if (value!.isEmpty) {
        return ("Please enter password");
      }
      if (!regex.hasMatch(value)) {
        return ("Invalid password");
      }
    } else {
      if (value!.isEmpty) {
        return ('');
      }
    }
    return null;
  }
}
