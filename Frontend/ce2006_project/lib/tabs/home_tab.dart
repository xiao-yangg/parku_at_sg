import 'dart:async';
import 'dart:convert' as convert;

import 'package:ce2006_project/components/custom_text_button.dart';
import 'package:ce2006_project/components/nav_bar_icons.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/custom_page_route.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/location.dart';
import 'package:ce2006_project/screens/all_screens_export.dart';
import 'package:ce2006_project/services/geolocator_service.dart';
import 'package:ce2006_project/tabs/all_tabs_export.dart';
import 'package:ce2006_project/widget/how_to_dialog.dart';
import 'package:ce2006_project/widget/speech_to_text_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// This is the AccountTab class also known as Account Page
/// Attributes:
/// endUser - current user
class HomeTab extends StatefulWidget {
  final AppUser endUser;
  late bool initialize;

  HomeTab({
    Key? key,
    required this.endUser,
    required this.initialize,
  }) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  NavBarIcons navBarIcons = NavBarIcons();
  int _selectedIndex = 0;

  bool splash = false; // to wait for Google Maps to completely build finish
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        splash = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        _backToCurrentLocation();
      });
    });
  }

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    Color kPrimaryColor =
        !widget.endUser.darkModeStatus ? kLightColor : kDarkColor;
    Color kSecondaryColor =
        !widget.endUser.darkModeStatus ? kDarkColor : kLightColor;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: kPrimaryColor,
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Text(
          kAppName,
          style: kAppTitleStyle.copyWith(fontSize: 30, color: kSecondaryColor),
        ),
        actions: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.tips_and_updates_outlined,
                  color: kSecondaryColor,
                ),
                onPressed: () {
                  // go to Updates Page
                  Navigator.of(context).push(
                    CustomPageRoute(
                      child: UpdatesScreen(
                        kPrimaryColor: kPrimaryColor,
                        kSecondaryColor: kSecondaryColor,
                      ),
                      direction: AxisDirection.up,
                    ),
                  );
                  setState(() {
                    if (widget.initialize) {
                      widget.initialize = !widget.initialize;
                    }
                  });
                },
              ),
              if (widget.initialize)
                Positioned(
                  top: 9,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(
            width: 5.0,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: splash
                ? Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                        // child: Container(
                        //   color: Colors.black,
                        // ),
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(
                              // Singapore
                              1.3521,
                              103.8198,
                            ),
                            zoom: 10.3,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                TextField(
                                  readOnly: true,
                                  textAlign: TextAlign.start,
                                  onTap: () {
                                    // go to Destination Page
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            DestinationScreen(
                                          endUser: widget.endUser,
                                          initialSearch: '',
                                        ),
                                      ),
                                    );
                                  },
                                  decoration: kSearchFieldDecoration.copyWith(
                                    filled: true,
                                    fillColor: kLightColor,
                                    hintText: 'Where to?',
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.mic,
                                      size: 28,
                                    ),
                                    color: kDarkColor,
                                    onPressed: () {
                                      // show Speech To Text Dialog
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            SpeechToTextDialog(
                                          endUser: widget.endUser,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 35),
                        alignment: Alignment.bottomLeft,
                        child: MaterialButton(
                          shape: const CircleBorder(),
                          color: kPrimaryColor,
                          padding: const EdgeInsets.all(15),
                          onPressed: () {
                            // show user current location on Google Maps
                            _updateCurrentLocation();
                            _backToCurrentLocation();
                          },
                          child: Icon(
                            Icons.gps_fixed,
                            color: kSecondaryColor,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20.0,
                            bottom: (0.15 * MediaQuery.of(context).size.height),
                          ),
                          child: Text(
                            'Location: ' +
                                widget.endUser.currentLocation.address
                                    .substring(
                                        0,
                                        widget.endUser.currentLocation.address
                                                .length -
                                            11) +
                                '\n\nCurrent Latitude: ' +
                                widget.endUser.currentLocation.latitude
                                    .toStringAsFixed(3) +
                                '\nCurrent Longitude: ' +
                                widget.endUser.currentLocation.longitude
                                    .toStringAsFixed(3),
                            style: kCardNormalTextStyle.copyWith(
                                color: kDarkColor),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: (0.12 * MediaQuery.of(context).size.height),
                            right: 15.0,
                          ),
                          child: SizedBox(
                            width: (0.4 * MediaQuery.of(context).size.width),
                            child: CustomTextButton(
                              function: () {
                                // go to Destination Page using user current location
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        DestinationScreen(
                                      endUser: widget.endUser,
                                      initialSearch: widget
                                          .endUser.currentLocation.address
                                          .substring(
                                              0,
                                              widget.endUser.currentLocation
                                                      .address.length -
                                                  11),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.map_outlined,
                                color: kDarkColor,
                                size: 15.0,
                              ),
                              text: 'Use My Location',
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: (0.14 * MediaQuery.of(context).size.height),
                            right: 15.0,
                          ),
                          child: SizedBox(
                            width: (0.27 * MediaQuery.of(context).size.width),
                            child: CustomTextButton(
                              function: () {
                                // show How To Dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const HowToDialog(),
                                );
                              },
                              icon: const Icon(
                                Icons.info_outline,
                                color: kDarkColor,
                                size: 15.0,
                              ),
                              text: 'How to?',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(
                          color: kSecondaryColor,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Searching for you...',
                          style: kCardNormalTextStyle.copyWith(
                            color: kSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0.0,
        items: navBarIcons.getNavBarIcons,
        iconSize: 28.0,
        currentIndex: _selectedIndex,
        selectedItemColor: kSecondaryColor,
        unselectedItemColor: kSecondaryColor,
        backgroundColor: kPrimaryColor,
        onTap: _onItemTapped,
      ),
    );
  }

  /// This function is used for switching between tabs in bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (_selectedIndex == 1) {
        // go to Bookmark Page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => BookmarkTab(
              endUser: widget.endUser,
              initialize: widget.initialize,
            ),
          ),
        );
      } else if (_selectedIndex == 2) {
        // go to Settings Page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => SettingsTab(
              endUser: widget.endUser,
              initialize: widget.initialize,
            ),
          ),
        );
      } else if (_selectedIndex == 3) {
        // go to Account Page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => AccountTab(
              endUser: widget.endUser,
              initialize: widget.initialize,
            ),
          ),
        );
      } else {}

      // change back so went go back index is original
      _selectedIndex = 0;
    });
  }

  /// This function is showing user current location on Google Maps
  Future<void> _backToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            widget.endUser.currentLocation.latitude,
            widget.endUser.currentLocation.longitude,
          ),
          zoom: 18,
        ),
      ),
    );
  }

  /// This function is used for updating user current location
  void _updateCurrentLocation() async {
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

    setState(() {
      widget.endUser.currentLocation =
          Location(address: addr, latitude: lat, longitude: lng);
    });
  }
}
