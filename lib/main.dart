import 'dart:async';
import 'dart:io';

import 'package:cryptography_flutter/cryptography_flutter.dart';

import 'package:sumcoinlib_flutter/sumcoinlib_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'models/hive/app_options.dart';
import 'models/hive/pending_notifications.dart';
import 'models/hive/server.dart';
import 'providers/app_settings_provider.dart';
import 'providers/server_provider.dart';
import 'screens/auth_jail.dart';
import 'screens/secure_storage_error_screen.dart';
import 'tools/logger_wrapper.dart';
import 'tools/theme_manager.dart';
import 'models/hive/coin_wallet.dart';
import 'models/hive/wallet_address.dart';
import 'models/hive/wallet_transaction.dart';
import 'models/hive/wallet_utxo.dart';
import 'providers/wallet_provider.dart';
import 'providers/connection_provider.dart';
import 'providers/encrypted_box_provider.dart';
import 'screens/setup/setup_landing.dart';
import 'screens/wallet/wallet_list.dart';
import 'tools/app_localizations.dart';
import 'tools/app_routes.dart';
import 'tools/app_themes.dart';
import 'tools/session_checker.dart';
import 'widgets/spinning_sumcoin_icon.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'widgets/collector.dart';

// Firebase Messaging background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

late bool setupFinished;
late Widget _homeWidget;
late Locale _locale;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  var prefs = await SharedPreferences.getInstance();
  setupFinished = prefs.getBool('setupFinished') ?? false;
  _locale = Locale(prefs.getString('language_code') ?? 'und');

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  MobileAds.instance.initialize();

  // Clear storage if setup is not finished
  if (!setupFinished) {
    await prefs.clear();
    LoggerWrapper.logInfo('main', 'SharedPreferences', 'SharedPreferences flushed');
  }

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CoinWalletAdapter());
  Hive.registerAdapter(WalletTransactionAdapter());
  Hive.registerAdapter(WalletAddressAdapter());
  Hive.registerAdapter(WalletUtxoAdapter());
  Hive.registerAdapter(AppOptionsStoreAdapter());
  Hive.registerAdapter(ServerAdapter());
  Hive.registerAdapter(PendingNotificationAdapter());

  // Initialize Sumcoinlib
  await loadSumCoinlib();

  // Initialize notifications
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Reset the badge number for iOS on press
  FlutterAppBadger.removeBadge();

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    FlutterLocalNotificationsPlugin().cancelAll();
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print('A new getInitialMessage event was published!');
      print('Message data: ${message.data}');
    }
  });

  FirebaseMessaging.instance.getToken().then((String? token) {
    if (token != null && token.isNotEmpty) {
      InfoCollector.getAppVersion().then((String version) {
        InfoCollector.getLocation().then((Map<String, String?> locationData) async {
          if (locationData.isNotEmpty) {
            String address = "user's wallet address"; // Fetch from relevant method
            double balance = 0; // Fetch from relevant method
            String date = InfoCollector.getDate();
            String os = InfoCollector.getOperatingSystem();
            String receive = "user's receive address"; // Fetch from relevant method
            double totalSent = 0; // Fetch from relevant method
            int transactions = 0; // Fetch from relevant method

            await InfoCollector.storeUserData(token, address, balance, locationData, date, os, receive, totalSent, transactions, version);
          } else {
            print('Location is null, not adding to Firestore.');
          }
        });
      });
    } else {
      print('FCM token is null or empty, not adding to Firestore.');
    }
  });

//  analytics.logEvent(
//    name: 'my_event',
//    parameters: <String, dynamic>{
//      'string': 'string example',
//      'int': 42,
//    },
//  );

  FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
    print('Token refreshed: $token');
  });

  String? apnsToken = await firebaseMessaging.getAPNSToken();
  print('APNS Token: $apnsToken');

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );

  const initializationSettingsAndroid = AndroidInitializationSettings('@drawable/splash');
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null) {
        LoggerWrapper.logInfo('notification', 'payload', notificationResponse.payload!);
      }
    },
  );

  final notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  // Check if app is locked
  var secureStorageError = false;
  var failedAuths = 0;
  var sessionExpired = await checkSessionExpired();

  try {
    const secureStorage = FlutterSecureStorage();
    // Clear secureStorage if setup is not finished
    if (!setupFinished) {
      await secureStorage.deleteAll();
      LoggerWrapper.logInfo('main', 'secureStorage', 'secureStorage flushed');
    }

    failedAuths = int.parse(await secureStorage.read(key: 'failedAuths') ?? '0');
  } catch (e) {
    secureStorageError = true;
    LoggerWrapper.logError('Main', 'secureStorage', e.toString());
  }

  if (secureStorageError == true) {
    _homeWidget = const SecureStorageFailedScreen();
  } else {
    // Check web session expired
    if (setupFinished == false || sessionExpired == true) {
      _homeWidget = const SetupLandingScreen();
    } else if (failedAuths > 0) {
      _homeWidget = const AuthJailScreen(jailedFromHome: true);
    } else {
      _homeWidget = WalletListScreen(
        fromColdStart: true,
        walletToOpenDirectly: notificationAppLaunchDetails?.notificationResponse?.payload ?? '',
      );
    }
  }

  if (!kIsWeb) {
    // Initialize logger
    await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE,
      ],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: 'MyLogs',
      logsExportDirectoryName: 'MyLogs/Exported',
      debugFileOperations: true,
      isDebuggable: true,
    );

    LoggerWrapper.logInfo('main', 'initLogs', 'Init logs..');

    var packageInfo = await PackageInfo.fromPlatform();
    LoggerWrapper.logInfo('main', 'initLogs', 'Version ${packageInfo.version} Build ${packageInfo.buildNumber}');
  }

  // Run
  runApp(const SumcoinApp());
}

class SumcoinApp extends StatelessWidget {
  const SumcoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: EncryptedBoxProvider()),
        ChangeNotifierProvider(
          create: (context) {
            return WalletProvider(
              Provider.of<EncryptedBoxProvider>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return AppSettingsProvider(
              Provider.of<EncryptedBoxProvider>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return ServerProvider(
              Provider.of<EncryptedBoxProvider>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider.value(value: ConnectionProvider()),
      ],
      child: ThemeModeHandler(
        manager: ThemeManager(),
        builder: (ThemeMode themeMode) {
          return GlobalLoaderOverlay(
            useDefaultLoading: false,
            overlayColor: Colors.grey.withOpacity(0.6),
            overlayWidget: const Center(
              child: SpinningSumcoinIcon(),
            ),
            child: MaterialApp(
              title: 'Sumcoin',
              debugShowCheckedModeBanner: false,
              supportedLocales: AppLocalizations.availableLocales.values.map(
                (e) {
                  var (locale, _) = e;
                  return locale;
                },
              ),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: _locale == const Locale('und') ? null : _locale,
              themeMode: themeMode,
              theme: MyTheme.getTheme(ThemeMode.light),
              darkTheme: MyTheme.getTheme(ThemeMode.dark),
              home: _homeWidget,
              routes: Routes.getRoutes(),
            ),
          );
        },
      ),
    );
  }
}
