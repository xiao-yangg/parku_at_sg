import 'package:flutter/material.dart';

/// This is the NavBarIcons class used in Home Page, Bookmark Page, Settings Page, Account Page
/// Attributes: none
class NavBarIcons {
  List<BottomNavigationBarItem> navIcons = const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(
        Icons.home_outlined,
      ),
      activeIcon: Icon(
        Icons.home_sharp,
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.bookmark_border,
      ),
      activeIcon: Icon(
        Icons.bookmark,
      ),
      label: 'Favorite',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.settings_outlined,
      ),
      activeIcon: Icon(
        Icons.settings,
      ),
      label: 'Settings',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.person_outlined,
      ),
      activeIcon: Icon(
        Icons.person,
      ),
      label: 'Account',
    ),
  ];

  /// This function returns the navigation bar icons
  List<BottomNavigationBarItem> get getNavBarIcons {
    return navIcons;
  }
}
