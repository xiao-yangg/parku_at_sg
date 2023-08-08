import 'package:ce2006_project/ad_helper.dart';
import 'package:ce2006_project/components/nav_bar_icons.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/tabs/all_tabs_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:restart_app/restart_app.dart';

/// This is the SettingsTab class also known as Settings Page
/// Attributes:
/// endUser - current user
class SettingsTab extends StatefulWidget {
  final AppUser endUser;
  final bool initialize;

  SettingsTab({
    Key? key,
    required this.endUser,
    required this.initialize,
  }) : super(key: key);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  NavBarIcons navBarIcons = NavBarIcons();
  int _selectedIndex = 2;

  final _firestore = FirebaseFirestore.instance;

  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

  bool restartApp = false;

  @override
  void initState() {
    super.initState();
    if (widget.endUser.adStatus) {
      _createBottomBannerAd();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.endUser.adStatus) {
      _bottomBannerAd.dispose();
    }
  }

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
          color: kSecondaryColor,
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: kAppTitleStyle.copyWith(fontSize: 30, color: kSecondaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Preferences',
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Light / Dark Mode',
                  style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
                ),
                FlutterSwitch(
                  width: 50,
                  height: 26.0,
                  valueFontSize: 10.0,
                  toggleSize: 15.0,
                  value: widget.endUser.darkModeStatus,
                  borderRadius: 30.0,
                  padding: 8.0,
                  showOnOff: true,
                  onToggle: (val) {
                    setState(() {
                      // toggle user darkModeStatus
                      widget.endUser.darkModeStatus = val;

                      // change color of page according to user darkModeStatus
                      if (widget.endUser.darkModeStatus) {
                        kPrimaryColor = kDarkColor;
                        kSecondaryColor = kLightColor;
                      } else {
                        kPrimaryColor = kLightColor;
                        kSecondaryColor = kDarkColor;
                      }
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Divider(
                color: kSecondaryColor,
                height: 5,
                thickness: 1.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'No Ads / Ads',
                  style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
                ),
                FlutterSwitch(
                  width: 50,
                  height: 26.0,
                  valueFontSize: 10.0,
                  toggleSize: 15.0,
                  value: widget.endUser.adStatus,
                  borderRadius: 30.0,
                  padding: 8.0,
                  showOnOff: true,
                  onToggle: (val) {
                    setState(() {
                      // toggle user darkModeStatus
                      widget.endUser.adStatus = val;
                    });

                    // update Firebase Firestore
                    User? loggedInUser = FirebaseAuth.instance.currentUser;

                    String? uid;
                    uid = loggedInUser?.uid;

                    _firestore
                        .collection(uid!)
                        .doc(widget.endUser.docId)
                        .update({
                      'id': widget.endUser.id,
                      'adStatus': widget.endUser.adStatus,
                      'darkModeStatus': widget.endUser.darkModeStatus,
                      'recents': widget.endUser.recents,
                      'bookmarks': widget.endUser.bookmarks,
                    });

                    Fluttertoast.showToast(msg: 'No Ads/Ads trigger restart');

                    // restart application
                    Future.delayed(const Duration(seconds: 1), () {
                      Restart.restartApp();
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Divider(
                color: kSecondaryColor,
                height: 5,
                thickness: 1.0,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'App Restart',
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Park Me!',
                  style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
                ),
                FlutterSwitch(
                  width: 50,
                  height: 26.0,
                  valueFontSize: 10.0,
                  toggleSize: 15.0,
                  value: restartApp,
                  borderRadius: 30.0,
                  padding: 8.0,
                  showOnOff: true,
                  onToggle: (val) {
                    setState(() {
                      restartApp = val;
                    });

                    // restart application (manual)
                    Future.delayed(const Duration(seconds: 1), () {
                      Restart.restartApp();
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Divider(
                color: kSecondaryColor,
                height: 5,
                thickness: 1.0,
              ),
            ),
            if (_isBottomBannerAdLoaded)
              SizedBox(
                height: _bottomBannerAd.size.height.toDouble(),
                width: _bottomBannerAd.size.width.toDouble(),
                child: AdWidget(ad: _bottomBannerAd),
              ),
          ],
        ),
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
      if (_selectedIndex == 0) {
        // go to Home Page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeTab(
              endUser: widget.endUser,
              initialize: widget.initialize,
            ),
          ),
        );
      } else if (_selectedIndex == 1) {
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
      _selectedIndex = 2;
    });
  }

  /// This function is for creating bottom banner ad
  void _createBottomBannerAd() {
    if (widget.endUser.adStatus) {
      _bottomBannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }),
      );

      _bottomBannerAd.load();
    }
  }
}
