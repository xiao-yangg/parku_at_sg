import 'dart:io';

/// This is the AdHelper class used in Bookmark Page, Settings Page, Account Page
class AdHelper {
  /// This function is used to retrieve banner ad id
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/6300978111";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/2934735716";
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// This function is used to retrieve interstitial ad id
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/8691691433";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/5135589807";
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
