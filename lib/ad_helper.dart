import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return '<ca-app-pub-1492791099222955/4791544403>';
    } else if (Platform.isIOS) {
      return '<ca-app-pub-1492791099222955/2003413748>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static AdRequest get adRequest => const AdRequest(
    keywords: <String>['finance', 'crypto'],
    nonPersonalizedAds: true,
  );

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return '<ca-app-pub-1492791099222955/4791544403>';
    } else if (Platform.isIOS) {
      return '<ca-app-pub-1492791099222955/2003413748>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return '<ca-app-pub-1492791099222955/4791544403>';
    } else if (Platform.isIOS) {
      return '<ca-app-pub-1492791099222955/2003413748>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
