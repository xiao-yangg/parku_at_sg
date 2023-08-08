import 'package:flutter/material.dart';

/// This is the CustomMaterialButton class used in CarparkInfoCard, CarparkSimpleCard, Login Page, Register Page, Welcome Page, Edit Page
/// Attributes:
/// function - execute certain function upon button press
/// text - display text on button
/// kPrimaryColor - primary color
/// kSecondaryColor - secondary color
class CustomMaterialButton extends StatelessWidget {
  final Function function;
  final String text;
  final Color kPrimaryColor;
  final Color kSecondaryColor;

  const CustomMaterialButton({
    Key? key,
    required this.function,
    required this.text,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSecondaryColor,
      borderRadius: const BorderRadius.all(
        Radius.circular(30.0),
      ),
      elevation: 5.0,
      child: MaterialButton(
        onPressed: () {
          function();
        },
        minWidth: 200.0,
        height: 42.0,
        child: Text(
          text,
          style: TextStyle(color: kPrimaryColor),
        ),
      ),
    );
  }
}
