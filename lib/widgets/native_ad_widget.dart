import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  // Add a key for VisibilityDetector
  NativeAdWidget({Key? key}) : super(key: key);

  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    disposeAd();
    super.dispose();
  }

  void loadAd() {
    if (_nativeAd == null) {
      _loadNativeAd();  // Load the ad here...
    }
  }

  void disposeAd() {
    print('Disposing of Native Ad');
    _nativeAd?.dispose();
    _nativeAd = null;  // Make sure to set _nativeAd to null to avoid using a disposed ad
  }

  void _loadNativeAd() {
    String adUnitId;
    if (Platform.isIOS) {
      adUnitId = 'ca-app-pub-1492791099222955/2003413748';  // iOS ad unit ID
    } else if (Platform.isAndroid) {
      adUnitId = 'ca-app-pub-1492791099222955/4791544403';  // Android ad unit ID
    } else {
      adUnitId = 'your_default_ad_unit_id';  // Default ad unit ID for other platforms
    }

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'your_custom_native_ad_factory_id',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('Native Ad loaded');
          setState(() {
            _nativeAd = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Native Ad failed to load: $error');
        },
      ),
    );
    print('Native Ad load requested');
    _nativeAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_nativeAd == null) {
      return const SizedBox();
    } else {
      return Container(
        height: 100.0,
        child: AdWidget(ad: _nativeAd!),
      );
    }
  }
}
