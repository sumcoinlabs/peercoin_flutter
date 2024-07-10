import 'package:sumcoinlib_flutter/sumcoinlib_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../widgets/banner_ad_widget.dart';
import '../../widgets/native_ad_widget.dart';
import '../../widgets/interstitial_ads.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/wallet_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/logger_wrapper.dart';
import '../../tools/price_ticker.dart';
import '../../widgets/buttons.dart';
import '../../widgets/double_tab_to_clipboard.dart';
import '../../widgets/service_container.dart';

class WalletMessageMigrationScreen extends StatefulWidget {
  const WalletMessageMigrationScreen({super.key});

  @override
  State<WalletMessageMigrationScreen> createState() =>
      _WalletMessageMigrationScreenState();
}

// To turn interstitial ads ON, on THIS page, uncomment the line, and comment out line below:
class _WalletMessageMigrationScreenState extends AdShowingState<WalletMessageMigrationScreen> {

// To turn interstitial ads OFF, on THIS page, uncomment the line, and comment out line above:
// class _WalletMessageMigrationScreenState extends State<WalletMessageMigrationScreen> {

// To adjust the timing of the ads, (Note: this is app wide ad every 5 mins. modify the Duration
// in the interstitial_ads.dart file:
// Future.delayed(Duration(seconds: 300), () {
//     loadAndShowAd();
// });

late WalletProvider _walletProvider;
bool _initial = true;
String _sumcoinPrice = '';
DateTime? _lastUpdated;

@override
void didChangeDependencies() {
  if (_initial == true) {
    _walletProvider = Provider.of<WalletProvider>(context);
    _fetchSumcoinPrice();
    setState(() {
      _initial = false;
    });
  }
  super.didChangeDependencies();
}

Future<void> _fetchSumcoinPrice() async {
  try {
    final data = await PriceTicker.getDataFromTicker();
    if (data.containsKey('SUM')) {
      setState(() {
        _sumcoinPrice = data['SUM'].toString();
        _lastUpdated = DateTime.now();
      });
    } else {
      setState(() {
        _sumcoinPrice = 'N/A';
      });
    }
  } catch (err) {
    setState(() {
      _sumcoinPrice = 'Error fetching price';
    });
  }
}

String _formatLastUpdated() {
  if (_lastUpdated == null) return '';
  return DateFormat('MM/dd/yyyy @ hh:mm a').format(_lastUpdated!.toLocal());
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text(
        AppLocalizations.instance.translate('wallet_pop_menu_slice_migration'),
      ),
    ),
    body: Column(
      children: [
        // Add the banner ad widget here.
        BannerAdWidget(),
        const SizedBox(height: 25),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'There is an UPCOMING Slice Wallet Migration Tool!',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '''Read the News from May on this below.''',
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  _buildFollowButton(
                    icon: Icons.newspaper,
                    label: 'Read May Migration News',
                    url: 'https://slicewallet.org/news/migration-pos-may-2024.html',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Currently Sumcoin Index is: \$$_sumcoinPrice',
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  if (_lastUpdated != null)
                    Text(
                      'Last updated: ${_formatLastUpdated()}',
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                  Text(
                    '''This page will be updated to load a tool which will allow you to take the 12 words of your Slice Wallet, and claim them here in the Sumcoin Wallet when you participate in app features over time.''',
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '''Sumcoin Wallet affiliates are excited for the upcoming migration and there will be opportunities to trade Sumcoin for goods, currencies, and services in the coming weeks.''',
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '''Please keep checking back for updates on the app store and below for more information. Until then, get some free SUM now from the faucet link below! ''',
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  _buildFollowButton(
                    icon: Icons.link,
                    label: 'Visit the Sumcoin Faucet',
                    url: 'https://sumcoinindex.com/faucets',
                  ),
                  // Add some space
                  const SizedBox(height: 25),
                  _buildFollowButton(
                    icon: Icons.link,
                    label: 'Learn more at Sumcoin.org ',
                    url: 'https://www.sumcoin.org',
                  ),
                  const SizedBox(height: 30),
                  _buildFollowButton(
                    icon: Icons.launch,
                    label: 'Follow Sumcoin Index on X (Twitter)',
                    url: 'https://x.com/sumcoinindex',
                  ),
                  const SizedBox(height: 15),
                  _buildFollowButton(
                    icon: Icons.wallet,
                    label: 'Follow Sumcoin Wallet on X (Twitter)',
                    url: 'https://x.com/sumcoinwallet',
                  ),
                  const SizedBox(height: 15),
                  _buildFollowButton(
                    icon: Icons.telegram,
                    label: 'Join Sumcoin on Telegram',
                    url: 'https://t.me/Sumcoins',
                  ),
                  const SizedBox(height: 15),
                  _buildFollowButton(
                    icon: Icons.discord,
                    label: 'Join the Sumcoin Discord',
                    url: 'https://discordapp.com/invite/ffJT5s8',
                  ),
                  const SizedBox(height: 15),
                  _buildFollowButton(
                    icon: Icons.video_library,
                    label: 'Subscribe to Sumcoin Index on YouTube',
                    url: 'https://www.youtube.com/channel/UC7nKLhuOgKCDzrkGhp4BPoA',
                  ),
                  const SizedBox(height: 15),
                  _buildFollowButton(
                    icon: Icons.code,
                    label: 'Follow Sumcoin on GitHub',
                    url: 'https://github.com/sumcoinlabs',
                  ),
                  // Add some space
                  const SizedBox(height: 25),
                  // Add the banner ad widget here.
                  BannerAdWidget(),
                  // Add the native ad widget here.
                  //const SizedBox(height: 25),
                  //NativeAdWidget(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton({required IconData icon, required String label, required String url}) {
    return TextButton.icon(
      icon: Icon(icon),
      onPressed: () {
        _launchURL(url);
      },
      label: Text(label),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
