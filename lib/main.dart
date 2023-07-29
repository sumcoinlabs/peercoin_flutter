import 'dart:async';

import 'package:cryptography_flutter/cryptography_flutter.dart';
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


import 'models/app_options.dart';
import 'models/pending_notifications.dart';
import './models/server.dart';
import 'providers/app_settings.dart';
import 'providers/servers.dart';
import 'screens/auth_jail.dart';
import 'screens/secure_storage_error_screen.dart';
import 'tools/logger_wrapper.dart';
import 'tools/theme_manager.dart';
import 'models/coin_wallet.dart';
import 'models/wallet_address.dart';
import 'models/wallet_transaction.dart';
import 'models/wallet_utxo.dart';
import 'providers/active_wallets.dart';
import 'providers/electrum_connection.dart';
import 'providers/encrypted_box.dart';
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
import 'tabs_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

bool setupFinished = false;
Widget _homeWidget = Container(); // Initialize with an empty Container or any other widget as a placeholder.
Locale _locale = Locale('en', 'US'); // Initialize with a default Locale. Modify this as per your needs.


FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

// The background message handler must be a top-level function.
// This function will be called to handle incoming messages when your app is in the background.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  setupFinished = prefs.getBool('setupFinished') ?? false;
  _locale = Locale(prefs.getString('language_code') ?? 'und');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//  await MobileAds.instance.initialize();

  await Hive.initFlutter();
  Hive.registerAdapter(CoinWalletAdapter());
  Hive.registerAdapter(WalletTransactionAdapter());
  Hive.registerAdapter(WalletAddressAdapter());
  Hive.registerAdapter(WalletUtxoAdapter());
  Hive.registerAdapter(AppOptionsStoreAdapter());
  Hive.registerAdapter(ServerAdapter());
  Hive.registerAdapter(PendingNotificationAdapter());

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationSettings settings = await _firebaseMessaging.requestPermission(
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
  });


  FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) {
    if (message != null) {
      print('A new getInitialMessage event was published!');
      print('Message data: ${message.data}');
    }
  });

  FirebaseMessaging.instance.getToken().then((String? token) {
    print('Token: $token');
  });

  analytics.logEvent(
      name: 'my_event',
      parameters: <String, dynamic>{
        'string': 'string example',
        'int': 42,
      },
  );

FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
    print('Token refreshed: $token');
  });

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  const initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/splash');
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (
      NotificationResponse notificationResponse,
    ) async {
      if (notificationResponse.payload != null) {
        LoggerWrapper.logInfo(
          'notification',
          'payload',
          notificationResponse.payload!,
        );
      }
    },
  );

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var secureStorageError = false;
  var failedAuths = 0;
  var sessionExpired = await checkSessionExpired();

  try {
    const secureStorage = FlutterSecureStorage();
    failedAuths =
        int.parse(await secureStorage.read(key: 'failedAuths') ?? '0');
  } catch (e) {
    secureStorageError = true;
    LoggerWrapper.logError('Main', 'secureStorage', e.toString());
  }

  if (secureStorageError == true) {
    _homeWidget = const SecureStorageFailedScreen();
  } else {
    if (setupFinished == false || sessionExpired == true) {
      _homeWidget = const SetupLandingScreen();
    } else if (failedAuths > 0) {
      _homeWidget = const AuthJailScreen(
        jailedFromHome: true,
      );
    } else {
      _homeWidget = WalletListScreen(
        fromColdStart: true,
        walletToOpenDirectly:
            notificationAppLaunchDetails?.notificationResponse?.payload ?? '',
      );
    }
  }

  if (!kIsWeb) {
    FlutterCryptography.enable();

    await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE
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
    LoggerWrapper.logInfo(
      'main',
      'initLogs',
      'Version ${packageInfo.version} Build ${packageInfo.buildNumber}',
    );
  }

  runApp(const SumcoinApp());
}

class SumcoinApp extends StatefulWidget {
  const SumcoinApp({Key? key}) : super(key: key);

  @override
  _SumcoinAppState createState() => _SumcoinAppState();
}

class _SumcoinAppState extends State<SumcoinApp> {
  // Initialize the location plugin
  Location location = Location();

  // This will hold the current location data
  LocationData? _locationData;

  // This will listen for location changes
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    _getLocation();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // existing code...
    });
  }

  // New function to get location data
  Future<void> _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
          setState(() {
            _locationData = currentLocation;
          });
        });

    print("Current Location: $_locationData");
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: EncryptedBox()),
        ChangeNotifierProvider(
          create: (context) {
            return ActiveWallets(
              Provider.of<EncryptedBox>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return AppSettings(
              Provider.of<EncryptedBox>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return Servers(
              Provider.of<EncryptedBox>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return ElectrumConnection(
              Provider.of<ActiveWallets>(context, listen: false),
              Provider.of<Servers>(context, listen: false),
            );
          },
        ),
      ],
      child: ThemeModeHandler(
        manager: ThemeManager(),
        builder: (ThemeMode themeMode) {
          return GlobalLoaderOverlay(
            useDefaultLoading: false,
            overlayOpacity: 0.6,
            overlayWidget: const Center(
              child: SpinningSumcoinIcon(),
            ),
            child: MaterialApp(
              title: 'Sumcoin',
              debugShowCheckedModeBanner: false,
              supportedLocales: AppLocalizations.availableLocales.keys
                  .map((lang) => Locale(lang)),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              locale: _locale == const Locale('und') ? null : _locale,
              themeMode: themeMode,
              theme: MyTheme.getTheme(ThemeMode.light),
              darkTheme: MyTheme.getTheme(ThemeMode.dark),
              home: _homeWidget,
              routes: Routes.getRoutes(),
              navigatorObservers: [observer],
            ),
          );
        },
      ),
    );
  }
}