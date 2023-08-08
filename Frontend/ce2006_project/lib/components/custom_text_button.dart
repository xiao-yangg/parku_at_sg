import 'package:ce2006_project/constants.dart';
import 'package:flutter/material.dart';

/// This is the CustomTextButton class used in Home Page, Trip Page
/// Attributes:
/// function - execute certain function upon button press
/// icon - icon of button
/// text - display text on button
class CustomTextButton extends StatelessWidget {
  final Function function;
  final Icon icon;
  final String text;

  const CustomTextButton({
    Key? key,
    required this.function,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        function();
      },
      style: TextButton.styleFrom(
        side: const BorderSide(color: kDarkColor, width: 2),
        backgroundColor: kLightColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
      ),
      child: Row(
        children: <Widget>[
          icon,
          const SizedBox(
            width: 5,
          ),
          Text(
            text,
            style: kCardNormalTextStyle.copyWith(
              color: kDarkColor,
            ),
          ),
        ],
      ),
    );
  }
}
