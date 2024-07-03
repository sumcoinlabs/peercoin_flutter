import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppReviewService {
  static const int _appOpensThreshold = 25; // Number of opens before showing the review prompt again
  static const String _appOpensKey = 'appOpens';
  static const String _reviewSubmittedKey = 'reviewSubmitted';

  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> incrementAppOpens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool reviewSubmitted = prefs.getBool(_reviewSubmittedKey) ?? false;

    if (!reviewSubmitted) {
      int appOpens = (prefs.getInt(_appOpensKey) ?? 0) + 1;
      await prefs.setInt(_appOpensKey, appOpens);

      if (appOpens % _appOpensThreshold == 0 && await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await prefs.setBool(_reviewSubmittedKey, true); // Mark that review was submitted
      }
    }
  }
}
