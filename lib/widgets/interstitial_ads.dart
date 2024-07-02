import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

InterstitialAd? _interstitialAd;
bool _isAdShowing = false;
bool _isLoadingAd = false;

String get adUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-1492791099222955/8429372244';
  } else if (Platform.isIOS) {
    return 'ca-app-pub-1492791099222955/5687658836';
  } else {
    // Placeholder for other platforms
    return '<YOUR_DEFAULT_AD_UNIT_ID>';
  }
}

void loadAndShowAd() {
  if (_isAdShowing || _isLoadingAd) return; // Prevent loading new ad if one is already showing or loading

  _isLoadingAd = true;
  InterstitialAd.load(
    adUnitId: adUnitId,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        _isLoadingAd = false;
        _interstitialAd = ad;
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad) {
            print('Ad showed full screen content.');
            _isAdShowing = true; // Ad is currently showing
          },
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
            _isAdShowing = false; // Ad is no longer showing
            Future.delayed(Duration(seconds: 300), () {
              // Delay before loading the next ad
              loadAndShowAd();
            });
          },
          onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
            print('Ad failed to show full screen content: $error');
            ad.dispose();
            _isAdShowing = false; // Ad is no longer showing
            Future.delayed(Duration(seconds: 300), () {
              // Delay before loading the next ad
              loadAndShowAd();
            });
          },
        );
        _interstitialAd!.show(); // Show the ad as soon as it's loaded
      },
      onAdFailedToLoad: (LoadAdError error) {
        _isLoadingAd = false;
        print('InterstitialAd failed to load: $error');
        _interstitialAd = null;
      },
    ),
  );
}

abstract class AdShowingState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    loadAndShowAd(); // Load and show the ad when the page initializes
  }
}
