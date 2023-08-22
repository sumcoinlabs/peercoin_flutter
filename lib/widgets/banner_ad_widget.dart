import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  @override
  void dispose() {
    disposeAd();
    super.dispose();
  }

  void loadAd() {
    String adUnitId;
    if (Platform.isIOS) {
      adUnitId = 'ca-app-pub-1492791099222955/3245006902'; // iOS ad unit ID
    } else if (Platform.isAndroid) {
      adUnitId = 'ca-app-pub-1492791099222955/5512077595'; // Android ad unit ID
    } else {
      adUnitId = 'your_default_ad_unit_id'; // Default ad unit ID for other platforms
    }

    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
    _bannerAd!.load();
  }

  void disposeAd() {
    _bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null) {
      return const SizedBox(); // Placeholder widget while the ad is loading
    } else {
      return Container(
        height: 100.0, // Adjust as needed
        child: AdWidget(ad: _bannerAd!),
      );
    }
  }
}
