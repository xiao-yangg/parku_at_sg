import 'package:ce2006_project/ad_helper.dart';
import 'package:ce2006_project/components/nav_bar_icons.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/custom_page_route.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/screens/all_screens_export.dart';
import 'package:ce2006_project/screens/authenticate/welcome_screen.dart';
import 'package:ce2006_project/tabs/all_tabs_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// This is the AccountTab class also known as Account Page
/// Attributes:
/// endUser - current user
class AccountTab extends StatefulWidget {
  final AppUser endUser;
  final bool initialize;

  const AccountTab({
    Key? key,
    required this.endUser,
    required this.initialize,
  }) : super(key: key);

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  NavBarIcons navBarIcons = NavBarIcons();
  int _selectedIndex = 3;

  final _firestore = FirebaseFirestore.instance;

  InterstitialAd? _interstitialAd;
  bool _isInlineBannerAdLoaded = false;
  int maxFailedLoadAttempts = 3;
  int _interstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    if (widget.endUser.adStatus) {
      _createInterstitialBannerAd();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.endUser.adStatus) {
      _interstitialAd?.dispose();
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
          'Account',
          style: kAppTitleStyle.copyWith(fontSize: 30, color: kSecondaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'General',
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 5,
            ),
            Subcategory(
              onPressed: () {
                if (widget.endUser.adStatus) {
                  _showInterstitialAd();
                }

                // go to Edit Page (Change Email)
                Navigator.of(context).push(
                  CustomPageRoute(
                    child: EditScreen(
                      particulars: 'Email',
                      kPrimaryColor: kPrimaryColor,
                      kSecondaryColor: kSecondaryColor,
                    ),
                    direction: AxisDirection.left,
                  ),
                );
              },
              textSample: 'Change Email',
              iconSample: Icon(
                Icons.arrow_forward_ios,
                color: kSecondaryColor,
                size: 15.0,
              ),
              kPrimaryColor: kPrimaryColor,
              kSecondaryColor: kSecondaryColor,
            ),
            Subcategory(
              onPressed: () {
                if (widget.endUser.adStatus) {
                  _showInterstitialAd();
                }

                // go to Edit Page (Change Password)
                Navigator.of(context).push(
                  CustomPageRoute(
                    child: EditScreen(
                      particulars: 'Password',
                      kPrimaryColor: kPrimaryColor,
                      kSecondaryColor: kSecondaryColor,
                    ),
                    direction: AxisDirection.left,
                  ),
                );
              },
              textSample: 'Change Password',
              iconSample: Icon(
                Icons.arrow_forward_ios,
                color: kSecondaryColor,
                size: 15.0,
              ),
              kPrimaryColor: kPrimaryColor,
              kSecondaryColor: kSecondaryColor,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'About us',
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 5,
            ),
            Subcategory(
              onPressed: () {
                if (widget.endUser.adStatus) {
                  _showInterstitialAd();
                }

                // go to Who Are We Page
                Navigator.of(context).push(
                  CustomPageRoute(
                    child: WhoAreWeScreen(
                      kPrimaryColor: kPrimaryColor,
                      kSecondaryColor: kSecondaryColor,
                    ),
                    direction: AxisDirection.left,
                  ),
                );
              },
              textSample: 'Who are we?',
              iconSample: Icon(
                Icons.arrow_forward_ios,
                color: kSecondaryColor,
                size: 15.0,
              ),
              kPrimaryColor: kPrimaryColor,
              kSecondaryColor: kSecondaryColor,
            ),
            Subcategory(
              onPressed: () {
                if (widget.endUser.adStatus) {
                  _showInterstitialAd();
                }

                // go to Contact Us Page
                Navigator.of(context).push(
                  CustomPageRoute(
                    child: ContactUsScreen(
                      kPrimaryColor: kPrimaryColor,
                      kSecondaryColor: kSecondaryColor,
                    ),
                    direction: AxisDirection.left,
                  ),
                );
              },
              textSample: 'Contact Us',
              iconSample: Icon(
                Icons.arrow_forward_ios,
                color: kSecondaryColor,
                size: 15.0,
              ),
              kPrimaryColor: kPrimaryColor,
              kSecondaryColor: kSecondaryColor,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'User',
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 5,
            ),
            Subcategory(
              onPressed: () {
                // update Firebase Firestore
                User? loggedInUser = FirebaseAuth.instance.currentUser;

                String? uid;
                uid = loggedInUser?.uid;

                _firestore.collection(uid!).doc(widget.endUser.docId).update({
                  'id': widget.endUser.id,
                  'adStatus': widget.endUser.adStatus,
                  'darkModeStatus': widget.endUser.darkModeStatus,
                  'recents': widget.endUser.recents,
                  'bookmarks': widget.endUser.bookmarks,
                });

                // sign out of Firebase Authentication
                FirebaseAuth.instance.signOut();

                // return to Welcome Page
                Navigator.pushNamedAndRemoveUntil(
                    context, WelcomeScreen.id, (Route<dynamic> route) => false);
              },
              textSample: 'Log out',
              iconSample: Icon(
                Icons.logout,
                color: kSecondaryColor,
                size: 15.0,
              ),
              kPrimaryColor: kPrimaryColor,
              kSecondaryColor: kSecondaryColor,
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
      } else {}

      // change back so went go back index is original
      _selectedIndex = 3;
    });
  }

  /// This function is for creating interstitial banner ad
  void _createInterstitialBannerAd() {
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          _isInlineBannerAdLoaded = true;
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        }, onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _interstitialLoadAttempts += 1;

          if (_interstitialLoadAttempts >= maxFailedLoadAttempts) {
            _createInterstitialBannerAd();
          } // try to load another ad if current ad fails
        }));
  }

  /// This function is for showing interstitial banner ad
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose(); // dispose old ad & add new one
        _createInterstitialBannerAd();
      }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialBannerAd();
      });
    }
    _interstitialAd!.show();
  }
}

/// This is the Subcategory class
/// Attributes:
/// onPressed - execute certain function
/// textSample - text to show
/// iconSample - icon to show
/// kPrimaryColor - primary color
/// kSecondaryColor - secondary color
class Subcategory extends StatelessWidget {
  final Function onPressed;
  final String textSample;
  final Icon iconSample;
  final Color kPrimaryColor;
  final Color kSecondaryColor;

  const Subcategory({
    Key? key,
    required this.onPressed,
    required this.textSample,
    required this.iconSample,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  textSample,
                  style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
                ),
                iconSample,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Divider(
            color: kSecondaryColor,
            height: 5,
            thickness: 1.0,
          ),
        ),
      ],
    );
  }
}
