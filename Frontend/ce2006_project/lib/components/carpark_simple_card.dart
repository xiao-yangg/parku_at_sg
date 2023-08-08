import 'package:ce2006_project/components/custom_material_button.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/carpark.dart';
import 'package:ce2006_project/widget/select_carpark.dart';
import 'package:flutter/material.dart';

/// This is the CarparkSimpleCard class used in Trip Page
/// Attributes:
/// carpark - a specific carpark
/// endUser - current user
/// bookmark - if carpark is bookmarked
class CarparkSimpleCard extends StatefulWidget {
  final Carpark carpark;
  final AppUser endUser;

  const CarparkSimpleCard({
    Key? key,
    required this.carpark,
    required this.endUser,
  }) : super(key: key);

  @override
  _CarparkSimpleCardState createState() => _CarparkSimpleCardState();
}

class _CarparkSimpleCardState extends State<CarparkSimpleCard> {
  bool bookmark = false;

  @override
  Widget build(BuildContext context) {
    checkBookmarkStatus();

    Color kPrimaryColor =
        !widget.endUser.darkModeStatus ? kLightColor : kDarkColor;
    Color kSecondaryColor =
        !widget.endUser.darkModeStatus ? kDarkColor : kLightColor;

    return Container(
      width: 5 * MediaQuery.of(context).size.width / 6,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: kSecondaryColor,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
        color: kPrimaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.carpark.id,
                style: kCardBoldTextStyle.copyWith(
                  color: kSecondaryColor,
                  fontSize: 17.0,
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
          Text(
            widget.carpark.location.address,
            style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
          ),
          Text(
            '(' + widget.carpark.information.type + ')',
            style: kCardNormalTextStyle.copyWith(
                color: kSecondaryColor, fontSize: 13.0),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Parking Rate: \$' + widget.carpark.rate.toStringAsFixed(2),
                style: kCardItalicsTextStyle.copyWith(color: kSecondaryColor),
              ),
              Text(
                'Distance: ' +
                    widget.carpark.distance.toStringAsFixed(2) +
                    'km',
                style: kCardItalicsTextStyle.copyWith(color: kSecondaryColor),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: CustomMaterialButton(
                  function: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: buildBottomSheet,
                    );
                  },
                  text: 'SELECT CARPARK',
                  kPrimaryColor: kPrimaryColor,
                  kSecondaryColor: kSecondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// This is the widget that builds SelectCarpark class which is also known as Carpark Widget
  Widget buildBottomSheet(BuildContext context) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SelectCarpark(
            carpark: widget.carpark,
            endUser: widget.endUser,
            infoView: false,
          ),
        ),
      );

  /// This function checks if carpark is bookmarked by user previously
  void checkBookmarkStatus() {
    for (String addr in widget.endUser.bookmarks) {
      if (addr == widget.carpark.location.address) {
        bookmark = true;
        break;
      }
    }
  }

  /// This function sets the bookmark status of a carpark
  void setBookmarkStatus() {
    setState(() {
      bookmark = !bookmark;
    });
    if (bookmark) {
      widget.endUser.bookmarks.insert(0, widget.carpark.location.address);
    } else {
      widget.endUser.bookmarks.remove(widget.carpark.location.address);
    }
  }
}
