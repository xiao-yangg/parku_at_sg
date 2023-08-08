import 'package:ce2006_project/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// This is the ContactUsScreen class also known as Contact Us Page
/// Attributes:
/// kPrimaryColor - primary color
/// kSecondaryColor - secondary color
/// email - developer's email
/// phone - developer's phone number
class ContactUsScreen extends StatefulWidget {
  final Color kPrimaryColor;
  final Color kSecondaryColor;

  const ContactUsScreen({
    Key? key,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String email = 'FutureEmployees@ask.com';
  String phone = '91234567';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.kPrimaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: widget.kSecondaryColor,
        ),
        backgroundColor: widget.kPrimaryColor,
        elevation: 0,
        title: Text(
          'Contact Us',
          style: kAppTitleStyle.copyWith(
              fontSize: 20, color: widget.kSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubContact(
              heading: 'Queries',
              text: 'Email us @',
              contact: email,
              function: () {
                launch(
                    'mailto://$email?subject=Queries%20ParkU@SG&body=hi%20there');
              },
              color: widget.kSecondaryColor,
            ),
            const SizedBox(
              height: 20.0,
            ),
            SubContact(
              heading: 'Feedbacks',
              text: 'Tell us @',
              contact: phone,
              function: () {
                launch('sms://$phone');
              },
              color: widget.kSecondaryColor,
            ),
            const SizedBox(
              height: 20.0,
            ),
            SubContact(
              heading: '24hr Hotline',
              text: 'Call us @',
              contact: phone,
              function: () {
                launch('tel://$phone');
              },
              color: widget.kSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// This is the Subcontact class
/// Attributes:
/// heading - displayed heading
/// text - displayed text
/// contact - contact information
/// function - execute certain function
/// color - color
class SubContact extends StatelessWidget {
  String heading;
  String text;
  String contact;
  Function function;
  Color color;

  SubContact({
    Key? key,
    required this.heading,
    required this.text,
    required this.contact,
    required this.function,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: kCardBoldTextStyle.copyWith(color: color),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: <Widget>[
            Text(
              text,
              style: kCardNormalTextStyle.copyWith(color: color),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                function();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Text(
                  contact,
                  style: kCardNormalTextStyle.copyWith(
                      color: color, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
