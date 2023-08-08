import 'package:flutter/material.dart';

/// This file contains all constants used throughout ParkU@SG

const kAPIKEY = '';
const kAppName = 'ParkU@SG';

const kLightColor = Color(0xffffffff); // light
const kDarkColor = Color(0xff212121); // dark

const kAppTitleStyle = TextStyle(
  fontFamily: 'Playfair Display',
  fontWeight: FontWeight.bold,
);

const kAppNormalStyle = TextStyle(
  fontFamily: 'Source Sans Pro',
  fontSize: 30.0,
  fontWeight: FontWeight.bold,
);

const kCardNormalTextStyle = TextStyle(
  fontFamily: 'Source Sans Pro',
  fontSize: 15.0,
);

const kCardBoldTextStyle = TextStyle(
  fontFamily: 'Source Sans Pro',
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
);

const kCardItalicsTextStyle = TextStyle(
  fontFamily: 'Source Sans Pro',
  fontSize: 15.0,
  fontStyle: FontStyle.italic,
);

const kBottomContainer = BoxDecoration(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(30.0),
    topRight: Radius.circular(30.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  filled: true,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(13.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kDarkColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(13.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kDarkColor, width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(13.0)),
  ),
);

const kSearchFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
  prefixIcon: Icon(
    Icons.location_on,
    color: kDarkColor,
    size: 28.0,
  ),
  filled: true,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kDarkColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kDarkColor, width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
);

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(13.0)),
  ),
);
