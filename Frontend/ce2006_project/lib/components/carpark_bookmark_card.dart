import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/screens/mains/destination_screen.dart';
import 'package:flutter/material.dart';

/// This is the CarparkBookmarkCard class used in Bookmark Page
/// Attributes:
/// carparkAddress - address of carpark
/// endUser - current user
/// bookmark - if carpark is bookmarked
class CarparkBookmarkCard extends StatefulWidget {
  final String carparkAddress;
  final AppUser endUser;

  const CarparkBookmarkCard({
    Key? key,
    required this.carparkAddress,
    required this.endUser,
  }) : super(key: key);

  @override
  _CarparkBookmarkCardState createState() => _CarparkBookmarkCardState();
}

class _CarparkBookmarkCardState extends State<CarparkBookmarkCard> {
  bool bookmark = true;

  @override
  Widget build(BuildContext context) {
    Color kPrimaryColor =
        !widget.endUser.darkModeStatus ? kLightColor : kDarkColor;
    Color kSecondaryColor =
        !widget.endUser.darkModeStatus ? kDarkColor : kLightColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: kSecondaryColor,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
        color: kPrimaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                // go to Destination Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DestinationScreen(
                      initialSearch: widget.carparkAddress,
                      endUser: widget.endUser,
                    ),
                  ),
                );
              });
            },
            child: Text(
              widget.carparkAddress,
              style: kCardBoldTextStyle.copyWith(
                  color: kSecondaryColor, fontSize: 17.0),
            ),
          ),
          GestureDetector(
            onTap: () {
              setBookmarkStatus();
            },
            child: Icon(
              bookmark ? Icons.bookmark : Icons.bookmark_border,
              color: kSecondaryColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// This function sets the bookmark status of a carpark
  void setBookmarkStatus() {
    setState(() {
      bookmark = !bookmark;
    });
    if (bookmark) {
      widget.endUser.bookmarks.insert(0, widget.carparkAddress);
    } else {
      widget.endUser.bookmarks.remove(widget.carparkAddress);
    }
  }
}
