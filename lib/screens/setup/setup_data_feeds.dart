import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../widgets/buttons.dart';
import 'setup_landing.dart';

class SetupDataFeedsScreen extends StatefulWidget {
  const SetupDataFeedsScreen({super.key});

  @override
  State<SetupDataFeedsScreen> createState() => _SetupDataFeedsScreenState();
}

class _SetupDataFeedsScreenState extends State<SetupDataFeedsScreen> {
  void _launchURL(String url) async {
    await canLaunchUrlString(url)
        ? await launchUrlString(
            url,
          )
        : throw 'Could not launch $url';
  }

  bool _dataFeedAllowed = true; // Set to true by default
  bool _bgSyncdAllowed = true;  // Set to true by default
  bool _initial = true;
  late AppSettingsProvider _settings;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _settings = context.read<AppSettingsProvider>();
      await _settings.init();

      //populate build identifier if not on web
      if (!kIsWeb) {
        var packageInfo = await PackageInfo.fromPlatform();
        _settings.setBuildIdentifier(packageInfo.buildNumber);
      }

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void togglePriceTickerHandler(bool newState) {
    _settings.setSelectedCurrency(newState == true ? 'USD' : '');

    setState(() {
      _dataFeedAllowed = newState;
    });
  }

  void toggleBGSyncHandler(bool newState) {
    _settings.setNotificationInterval(newState == true ? 60 : 0);

    setState(() {
      _bgSyncdAllowed = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SetupLandingScreen.calcContainerHeight(context),
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const PeerProgress(step: 4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Image.asset(
                      'assets/img/setup-consent.png',
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const PeerButtonSetupBack(),
                        AutoSizeText(
                          AppLocalizations.instance
                              .translate('setup_price_feed_title'),
                          minFontSize: 24,
                          maxFontSize: 28,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width > 1200
                            ? MediaQuery.of(context).size.width / 2
                            : MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SwitchListTile(
                                key: const Key('setupApiTickerSwitchKey'),
                                title: Text(
                                  AppLocalizations.instance
                                      .translate('setup_price_feed_allow'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                value: _dataFeedAllowed,
                                activeColor: Colors.white,
                                inactiveThumbColor: Colors.grey,
                                onChanged: (newState) =>
                                    togglePriceTickerHandler(newState),
                              ),
                            ),
                            PeerExplanationText(
                              text: AppLocalizations.instance.translate(
                                'setup_price_feed_description',
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!kIsWeb)
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width > 1200
                              ? MediaQuery.of(context).size.width / 2
                              : MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: SwitchListTile(
                                  key: const Key('setupApiBGSwitchKey'),
                                  title: Text(
                                    AppLocalizations.instance
                                        .translate('setup_bg_sync_allow'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  value: _bgSyncdAllowed,
                                  activeColor: Colors.white,
                                  inactiveThumbColor: Colors.grey,
                                  onChanged: (newState) =>
                                      toggleBGSyncHandler(newState),
                                ),
                              ),
                              PeerExplanationText(
                                text: AppLocalizations.instance.translate(
                                  'setup_bg_sync_description',
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    PeerButton(
                      action: () => _launchURL(
                        'https://github.com/sumcoinlabs/sumcoin_flutter/blob/main/data_protection.md',
                      ),
                      text: AppLocalizations.instance
                          .translate('about_data_declaration'),
                    ),
                  ],
                ),
              ),
              PeerButtonSetup(
                text: AppLocalizations.instance.translate('continue'),
                action: () {
                  Navigator.of(context).pushNamed(Routes.setupLegal);
                },
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
