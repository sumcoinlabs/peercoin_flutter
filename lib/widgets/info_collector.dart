import 'dart:io';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import '../providers/active_wallets.dart';

//class InfoCollector {
//  final ActiveWallets _activeWallets;

//  InfoCollector(this._activeWallets);

  // Gets the current date and time.
  static String getDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('MM/dd/yy h:mm a');
    return formatter.format(now);
  }

  // Determines the operating system.
  static String getOperatingSystem() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  // Fetches the app version.
  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // Fetches the user's location.
  static Future<Map<String, String?>> getLocation() async {
    if (!(await Geolocator.isLocationServiceEnabled())) return {};

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return {};  // Location permissions are denied.
      }
    }

    Position position = await Geolocator.getCurrentPosition();
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

  // Generate a unique ID for each user.
  String generateUniqueID() {
    var uuid = Uuid();
    return uuid.v1(); // Generates a unique v1 UUID
  }

  // Store user data in Firestore.
  Future<void> storeUserData() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    String address = await _activeWallets.getUnusedAddress;
    double balance = await _activeWallets.activeWalletsValues.first.balance;

    String date = getDate();
    String os = getOperatingSystem();
    String version = await getAppVersion();
    Map<String, String?> locationData = await getLocation();
    String uniqueID = generateUniqueID();

    if (fcmToken != null && fcmToken.isNotEmpty) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('wallets').doc(uniqueID).set({
          'FCMToken': fcmToken,
          'balance': balance.toDouble(), // Convert balance to double
          ...locationData,
          'date': date,
          'os': os,
          'version': version,
          'walletAddress': address,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Failed to add user data to Firestore: $e");
      }
    } else {
      print('FCM token is null or empty, not adding to Firestore.');
    }
  }
}
