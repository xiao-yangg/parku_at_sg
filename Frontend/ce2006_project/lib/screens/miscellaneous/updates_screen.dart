import 'package:ce2006_project/constants.dart';
import 'package:flutter/material.dart';

/// This is the UpdatesScreen class also known as Updates Page
/// Attributes:
/// kPrimaryColor - primary color
/// kSecondaryColor - secondary color
class UpdatesScreen extends StatelessWidget {
  final Color kPrimaryColor;
  final Color kSecondaryColor;

  const UpdatesScreen({
    Key? key,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: kSecondaryColor,
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Text(
          'UPDATE',
          style: kAppTitleStyle.copyWith(fontSize: 20, color: kSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'What\'s new',
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 8,
            ),
            UnorderedList(
              texts: const [
                "Bookmark your favorite carparks for future trips!",
                "Entertaining ads in app!",
                "Minor bug fixes v2.1.1",
              ],
              kPrimaryColor: kPrimaryColor,
              kSecondaryColor: kSecondaryColor,
            ),
            const SizedBox(
              height: 30.0,
            ),
            Text(
              'What\'s coming',
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 8,
            ),
            UnorderedList(
              texts: const [
                "Voice-to-text search (hopefully)",
                "Include shopping mall carparks database",
                "Parking rates for motorcyclists users",
              ],
              kPrimaryColor: kPrimaryColor,
              kSecondaryColor: kSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// This is the UnorderedList class to show unordered list
/// Attributes:
/// texts - list of texts
class UnorderedList extends StatelessWidget {
  final List<String> texts;
  final Color kPrimaryColor;
  final Color kSecondaryColor;
  const UnorderedList({
    Key? key,
    required this.texts,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      // Add list item
      widgetList.add(UnorderedListItem(
        text: text,
        kPrimaryColor: kPrimaryColor,
        kSecondaryColor: kSecondaryColor,
      ));
      // Add space between items
      widgetList.add(const SizedBox(height: 8.0));
    }

    return Column(children: widgetList);
  }
}

/// This is the UnorderedListItem class for unordered list
/// Attributes:
/// text - text
class UnorderedListItem extends StatelessWidget {
  final String text;
  final Color kPrimaryColor;
  final Color kSecondaryColor;

  const UnorderedListItem({
    Key? key,
    required this.text,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "• ",
          style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
        ),
        Expanded(
          child: Text(
            text,
            style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
          ),
        ),
      ],
    );
  }
}
