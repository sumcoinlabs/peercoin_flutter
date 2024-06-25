import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hive/coin_wallet.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/background_sync.dart';
import '../../widgets/buttons.dart';

class AppSettingsNotificationsScreen extends StatefulWidget {
  const AppSettingsNotificationsScreen({super.key});

  @override
  State<AppSettingsNotificationsScreen> createState() =>
      _AppSettingsNotificationsScreenState();
}

class _AppSettingsNotificationsScreenState
    extends State<AppSettingsNotificationsScreen> {
  bool _initial = true;
  late AppSettingsProvider _appSettings;
  late WalletProvider _walletProvider;
  List<CoinWallet> _availableWallets = [];

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _appSettings = Provider.of<AppSettingsProvider>(context);
      _walletProvider = context.watch<WalletProvider>();
      _availableWallets = _walletProvider.availableWalletValues;
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<void> enableNotifications(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('setup_continue_alert_title'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.instance
                .translate('app_settings_notifications_alert_content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () async {
                _appSettings.setNotificationInterval(60);
                final navigator = Navigator.of(context);

                var walletList = <String>[];
                for (var element in _availableWallets) {
                  walletList.add(element.letterCode);
                }
                _appSettings.setNotificationActiveWallets(walletList);

                await BackgroundSync.init(
                  notificationInterval: _appSettings.notificationInterval,
                  needsStart: true,
                );

                await BackgroundSync.executeSync(fromScan: true);
                navigator.pop();
              },
              child: Text(
                AppLocalizations.instance.translate('continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget enableBlock() {
    return Column(
      children: [
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_not_enabled'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        const Divider(),
        PeerButton(
          text: AppLocalizations.instance
              .translate('app_settings_notifications_enable_button'),
          action: () async {
            await enableNotifications(context);
          },
        ),
      ],
    );
  }

  void saveSnack(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate('app_settings_saved_snack'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget manageBlock() {
    return Column(
      children: [
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_heading_manage_wallets'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Column(
          children: _availableWallets.map((wallet) {
            return SwitchListTile(
              key: Key(wallet.name),
              title: Text(wallet.title),
              value:
                  _appSettings.notificationActiveWallets.contains(wallet.name),
              onChanged: (newState) {
                var newList = _appSettings.notificationActiveWallets;
                if (newState == true) {
                  newList.add(wallet.name);
                } else {
                  newList.remove(wallet.name);
                }
                _appSettings.setNotificationActiveWallets(newList);
                saveSnack(context);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_heading_interval'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_hint_sync_1', {
            'minutes': _appSettings.notificationInterval.toString(),
          }),
        ),
        Slider(
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Theme.of(context).shadowColor,
          value: _appSettings.notificationInterval.toDouble(),
          min: 15,
          max: 60,
          divisions: 3,
          onChangeEnd: (e) async {
            saveSnack(context);
            await BackgroundSync.init(
              notificationInterval: _appSettings.notificationInterval,
            );
          },
          label: _appSettings.notificationInterval.toString(),
          onChanged: (e) => _appSettings.setNotificationInterval(
            e.toInt(),
          ),
        ),
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_hint_sync_2'),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 10),
        PeerButton(
          text: AppLocalizations.instance
              .translate('app_settings_notifications_disable_button'),
          action: () async {
            await BackgroundFetch.stop();
            _appSettings.setNotificationInterval(0);
            _appSettings.setNotificationActiveWallets([]);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('app_settings_notifications'),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _appSettings.notificationInterval == 0
                      ? enableBlock()
                      : manageBlock(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
