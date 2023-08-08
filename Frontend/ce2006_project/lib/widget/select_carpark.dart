import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:ce2006_project/components/numeric_step_button.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/carpark.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';

/// This is the SelectCarpark class also known as Carpark Widget used in Trip Screen
/// Attributes:
/// carpark - user selected carpark
/// endUser - current user
class SelectCarpark extends StatefulWidget {
  final Carpark carpark;
  final AppUser endUser;
  final bool infoView;

  const SelectCarpark({
    Key? key,
    required this.carpark,
    required this.endUser,
    required this.infoView,
  }) : super(key: key);

  @override
  _SelectCarparkState createState() => _SelectCarparkState();
}

class _SelectCarparkState extends State<SelectCarpark> {
  int hours = 0;
  String totalAmount = '0.00';

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Color kPrimaryColor =
        !widget.endUser.darkModeStatus ? kLightColor : kDarkColor;
    Color kSecondaryColor =
        !widget.endUser.darkModeStatus ? kDarkColor : kLightColor;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: (widget.endUser.darkModeStatus && widget.infoView)
              ? const Color(0xff191822)
              : const Color(0xff757575),
        ),
        color: (widget.endUser.darkModeStatus && widget.infoView)
            ? const Color(0xff191822)
            : const Color(0xff757575),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 30,
        ),
        decoration: kBottomContainer.copyWith(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
          ),
          color: kPrimaryColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.carpark.location.address,
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              'Parking Type: ' + widget.carpark.information.parkingSystem,
              style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Gantry Height: ' +
                      double.parse(widget.carpark.information.gantryHeight)
                          .toStringAsFixed(2) +
                      'm',
                  style: kCardItalicsTextStyle.copyWith(color: kSecondaryColor),
                ),
                Text(
                  (widget.carpark.information.nightParking)
                      ? 'Night Parking: YES'
                      : 'Night Parking: NO',
                  style: kCardItalicsTextStyle.copyWith(color: kSecondaryColor),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              'Current Parking Rate: \$' +
                  widget.carpark.rate.toStringAsFixed(2),
              style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: 150.0,
                  width: 140.0,
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: kPrimaryColor,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.directions_car,
                        size: 40.0,
                        color: kSecondaryColor,
                      ),
                      Text(
                        'Vehicle:',
                        style: kCardItalicsTextStyle.copyWith(
                            color: kSecondaryColor),
                      ),
                      const SizedBox(
                        height: 1.0,
                      ),
                      Text(
                        'Car',
                        style: kCardNormalTextStyle.copyWith(
                            color: kSecondaryColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 150.0,
                  width: 140.0,
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: kPrimaryColor,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        size: 40.0,
                        color: kSecondaryColor,
                      ),
                      Text(
                        'No. of hours:',
                        style: kCardItalicsTextStyle.copyWith(
                            color: kSecondaryColor),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      NumericStepButton(
                        maxValue: 24,
                        onChanged: (value) {
                          hours = value;
                          updateText();
                        },
                        kPrimaryColor: kPrimaryColor,
                        kSecondaryColor: kSecondaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '\$ ' + totalAmount,
                  style: kAppNormalStyle.copyWith(
                    color: kSecondaryColor,
                  ),
                ),
                const SizedBox(
                  width: 40.0,
                ),
                ElevatedButton(
                  style: raisedButtonStyle.copyWith(
                      backgroundColor:
                          MaterialStateProperty.all(kSecondaryColor)),
                  onPressed: () {
                    /// Keeping selected carpark to recents record before navigation
                    bool flag = false;

                    int len = widget.endUser.recents.length;
                    String addr = (widget.carpark.location.address.length > 32)
                        ? widget.carpark.location.address.substring(0, 32)
                        : widget.carpark.location.address;

                    // checking if selected carpark already exist in recent
                    // NOTE can also print reverse list so add instead of insert at 0
                    for (int i = 0; i < len; i++) {
                      if (widget.endUser.recents[i] == addr) {
                        // remove earliest and put to latest
                        widget.endUser.recents.removeAt(i);
                        widget.endUser.recents.insert(0, addr);

                        flag = true;
                        break;
                      }
                    }

                    // insert into recents if selected carpark is not in recent (max 5 recents)
                    if (!flag) {
                      widget.endUser.recents.insert(0, addr);

                      if (len == 5) {
                        // previously 5, insert = 6
                        widget.endUser.recents.removeAt(5);
                      }
                    }

                    // update Firebase Firestore
                    User? loggedInUser = FirebaseAuth.instance.currentUser;

                    String? uid;
                    uid = loggedInUser?.uid;

                    _firestore
                        .collection(uid!)
                        .doc(widget.endUser.docId)
                        .update({
                      'bookmarks': widget.endUser.bookmarks,
                      'darkModeStatus': widget.endUser.darkModeStatus,
                      'id': widget.endUser.id,
                      'recents': widget.endUser.recents,
                    });

                    // open native Google Map application
                    _launcherMapsUrl(
                      widget.endUser.currentLocation.latitude,
                      widget.endUser.currentLocation.longitude,
                      widget.carpark.location.latitude,
                      widget.carpark.location.longitude,
                    );

                    // exit ParkU@SG
                    if (const LocalPlatform().isAndroid) {
                      SystemNavigator.pop();
                    } else {
                      exit(0);
                    }
                  },
                  child: Text(
                    'Go!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// This function is used for showing calculation of parking rate base on hours user is parking
  void updateText() {
    setState(() {
      totalAmount = (hours * widget.carpark.rate).toStringAsFixed(2);
      // print(totalAmount);
    });
  }

  /// This function is used for launching native Google Map application
  void _launcherMapsUrl(double originLat, double originLng, double destLat,
      double destLng) async {
    if (const LocalPlatform().isAndroid) {
      final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull(
              "https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving&dir_action=navigate"),
          package: 'com.google.android.apps.maps');
      intent.launch();
    } else {
      String url =
          "https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving&dir_action=navigate";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
