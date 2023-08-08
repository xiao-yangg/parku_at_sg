import 'package:ce2006_project/ad_helper.dart';
import 'package:ce2006_project/components/carpark_bookmark_card.dart';
import 'package:ce2006_project/components/nav_bar_icons.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/tabs/all_tabs_export.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// This is the BookmarkTab class also known as Bookmark Page
/// Attributes:
/// endUser - current user
/// bookmarkResults - bookmarks of user
class BookmarkTab extends StatefulWidget {
  final AppUser endUser;
  final bool initialize;

  const BookmarkTab({
    Key? key,
    required this.endUser,
    required this.initialize,
  }) : super(key: key);

  @override
  _BookmarkTabState createState() => _BookmarkTabState();
}

class _BookmarkTabState extends State<BookmarkTab> {
  NavBarIcons navBarIcons = NavBarIcons();
  int _selectedIndex = 1;

  final _inlineAdIndex = 3;
  late BannerAd _inlineBannerAd;
  bool _isInlineBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.endUser.adStatus) {
      _createInlineBannerAd();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.endUser.adStatus) {
      _inlineBannerAd.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    List bookmarkResults = widget.endUser.bookmarks;

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
          'Bookmark',
          style: kAppTitleStyle.copyWith(fontSize: 30, color: kSecondaryColor),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Locations',
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Divider(
                color: kSecondaryColor,
                height: 20,
                thickness: 2.0,
              ),
            ),
            Expanded(
              child: (bookmarkResults.isEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Nothing found',
                        style: kCardNormalTextStyle.copyWith(
                          color: kSecondaryColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: bookmarkResults.length +
                          (_isInlineBannerAdLoaded ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isInlineBannerAdLoaded &&
                            index == _inlineAdIndex) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                            ),
                            height: _inlineBannerAd.size.height.toDouble(),
                            width: _inlineBannerAd.size.width.toDouble(),
                            child: AdWidget(ad: _inlineBannerAd),
                          );
                        } else {
                          return CarparkBookmarkCard(
                            carparkAddress:
                                bookmarkResults[_getListViewItemIndex(index)],
                            endUser: widget.endUser,
                          );
                        }
                      }),
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
      _selectedIndex = 1;
    });
  }

  /// This function is used for creating inline banner ads
  void _createInlineBannerAd() {
    if (widget.endUser.adStatus) {
      _inlineBannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: AdSize.mediumRectangle,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isInlineBannerAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }),
      );

      _inlineBannerAd.load();
    }
  }

  /// This function is used for getting current index of listview to load inline banner ads
  int _getListViewItemIndex(int index) {
    if (index >= _inlineAdIndex && _isInlineBannerAdLoaded) {
      return index - 1;
    } else {
      return index;
    }
  }
}
