import 'package:ce2006_project/constants.dart';
import 'package:flutter/material.dart';

/// This is the HowToDialog class used in Home Page
/// Attributes: none
class HowToDialog extends StatelessWidget {
  const HowToDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 150.0, horizontal: 30.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          color: kLightColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: kDarkColor,
                  size: 25.0,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  'How to use ParkU@SG?',
                  style: kCardNormalTextStyle.copyWith(
                      color: kDarkColor, fontSize: 20.0),
                ),
              ],
            ),
            SingleChildScrollView(
              reverse: true,
              child: Text(
                _kHowToUseDescription,
                style: kCardNormalTextStyle.copyWith(
                    color: kDarkColor, fontSize: 15.0),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Back',
                style: kCardItalicsTextStyle.copyWith(
                    color: kDarkColor, fontSize: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// This is the basic steps to navigating ParkU@SG
const _kHowToUseDescription = """
Step 1: Tap on search bar

Step 2: Input desired destination

Step 3: Select carpark filters

Step 4: Choose preferred carpark

Step 5: Go a for ride!
""";
