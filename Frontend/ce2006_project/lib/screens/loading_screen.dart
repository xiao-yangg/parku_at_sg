import 'dart:convert' as convert;

import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/location.dart';
import 'package:ce2006_project/services/all_services_export.dart';
import 'package:ce2006_project/tabs/home_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

/// This is the LoadingScreen class also known as Loading Page
/// Attributes:
/// loggedInUser - current logged in user base on Firebase Authentication
/// endUser - current user
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  // static const String id = 'loading_screen'; // testing

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  User? loggedInUser = FirebaseAuth.instance.currentUser;
  late AppUser endUser;

  @override
  void initState() {
    super.initState();
    getLocationFirebaseData();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kDarkColor,
      body: Center(
        child: SpinKitDoubleBounce(
          color: kLightColor,
          size: 100.0,
        ),
      ),
    );
  }

  /// This function is used to get user current location and saved data from Firebase Firestore
  void getLocationFirebaseData() async {
    const key = kAPIKEY;

    // user location
    var geolocatorProvider = await GeolocatorService().getCurrentLocation();

    // user address from Google
    double lat = geolocatorProvider.latitude;
    double lng = geolocatorProvider.longitude;

    var url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    String addr = json['results'][0]['formatted_address'];

    // Firebase authentication
    String? uid;
    uid = loggedInUser?.uid;

    var data = await FirebaseFirestore.instance.collection(uid!).get();
    // print(loggedInUser);

    endUser = AppUser(
      bookmarks: data.docs[0].data()['bookmarks'],
      darkModeStatus: data.docs[0].data()['darkModeStatus'],
      adStatus: data.docs[0].data()['adStatus'],
      id: data.docs[0].data()['id'],
      recents: data.docs[0].data()['recents'],
      docId: data.docs[0].id,
      currentLocation: Location(address: addr, latitude: lat, longitude: lng),
    );

    Future.delayed(const Duration(milliseconds: 200), () {});

    // go to Home Page
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeTab(
            endUser: endUser,
            initialize: true,
          ),
        ),
        (Route<dynamic> route) => false);
  }
}
