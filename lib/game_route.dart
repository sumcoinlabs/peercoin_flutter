...

// TODO: Import ad_helper.dart
import 'package:awesome_drawing_quiz/ad_helper.dart';

// TODO: Import google_mobile_ads.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameRoute extends StatefulWidget {
// TODO: Add _bannerAd
BannerAd? _bannerAd;
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    ...
    body: SafeArea(
      child: Stack(
        children: [
          Center(
            ...
          ),
          // TODO: Display a banner when ready
          if (_bannerAd != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    ),
    ...
  );
}
