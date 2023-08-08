import 'package:ce2006_project/models/location.dart';

/// This is the AppUser class
/// Attributes:
/// bookmarks - list of user bookmarks
/// darkModeStatus - whether user choose dark mode
/// adStatus - whether user choose to turn on ads
/// id - user document id in Firebase Firestore
/// recents - list of user recents
/// docId - uid of user in Firebase Authentication
/// currentLocation - user current location
class AppUser {
  List bookmarks;
  bool darkModeStatus;
  bool adStatus;
  String id;
  List recents;
  String docId; // uid
  Location currentLocation;

  AppUser({
    required this.bookmarks,
    required this.darkModeStatus,
    required this.adStatus,
    required this.id,
    required this.recents,
    required this.docId,
    required this.currentLocation,
  });
}
