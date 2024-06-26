import 'package:sumcoinlib_flutter/sumcoinlib_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/connection_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/background_sync.dart';
import '../../tools/validators.dart';
import '../../widgets/buttons.dart';
import '../../widgets/service_container.dart';

class ImportWifScreen extends StatefulWidget {
  const ImportWifScreen({super.key});

  @override
  State<ImportWifScreen> createState() => _ImportWifScreenState();
}

class _ImportWifScreenState extends State<ImportWifScreen> {
  late Coin _activeCoin;
  late String _walletName;
  bool _initial = true;
  late WalletProvider _walletProvider;
  late ConnectionProvider _electrumConnection;
  final _wifGlobalKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final _wifController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        _walletName = ModalRoute.of(context)!.settings.arguments as String;
        _activeCoin = AvailableCoins.getSpecificCoin(_walletName);
        _walletProvider = Provider.of<WalletProvider>(context);
        _electrumConnection = Provider.of<ConnectionProvider>(context);
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void createQrScanner(String keyType) async {
    final result = await Navigator.of(context).pushNamed(
      Routes.qrScan,
      arguments: AppLocalizations.instance.translate('paperwallet_step_2_text'),
    );
    if (result != null) {
      _wifController.text = (result as String).trim();
    }
  }

  Future<void> performImport(String wif, String address) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    //write to wallet
    await _walletProvider.addAddressFromWif(
      identifier: _walletName,
      wif: wif,
      address: address,
    );

    //subscribe
    _electrumConnection.subscribeToScriptHashes(
      {
        address: _walletProvider.getScriptHash(_walletName, address),
      },
    );

    //set to watched
    await _walletProvider.updateAddressWatched(_walletName, address, true);

    //sync background notification
    await BackgroundSync.executeSync(fromScan: true);

    //send snack notification for success
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate('import_wif_success_snack'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    //pop import wif
    navigator.pop();
  }

  Future<void> triggerConfirmMessage(BuildContext ctx, String privKey) async {
    final scaffoldMessenger = ScaffoldMessenger.of(ctx);
    final publicAddress = P2PKHAddress.fromPublicKey(
      WIF.fromString(privKey).privkey.pubkey,
      version: _activeCoin.networkType.p2pkhPrefix,
    ).toString();
    //TODO won't return a bech32 addr, but a P2PKH address

    //check if that address is already in the list
    final walletAddresses = await _walletProvider.getWalletAddresses(
      _walletName,
    );
    final specificAddressResult = walletAddresses.where(
      (element) => element.address == publicAddress,
    );

    if (specificAddressResult.isNotEmpty) {
      //we have that address already
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate('import_wif_error_snack'),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      if (context.mounted) {
        await showDialog(
          context: ctx,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                AppLocalizations.instance
                    .translate('paperwallet_confirm_import'),
                textAlign: TextAlign.center,
              ),
              content: Text(
                AppLocalizations.instance.translate(
                  'import_wif_alert_content',
                  {'address': publicAddress},
                ),
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
                    Navigator.pop(context);
                    await performImport(privKey, publicAddress);
                  },
                  child: Text(
                    AppLocalizations.instance.translate('import_button'),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('wallet_pop_menu_wif'),
        ),
      ),
      body: Align(
        child: PeerContainer(
          noSpacers: true,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.instance
                                .translate('import_wif_intro'),
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            key: _wifGlobalKey,
                            controller: _wifController,
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.instance
                                    .translate('import_wif_error_empty');
                              }
                              if (validateWIFPrivKey(value) == false) {
                                return AppLocalizations.instance
                                    .translate('import_wif_error_failed_parse');
                              }

                              triggerConfirmMessage(context, value);
                              return null;
                            },
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.vpn_key,
                                color: Theme.of(context).primaryColor,
                              ),
                              labelText: AppLocalizations.instance
                                  .translate('import_wif_textfield_label'),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  var data =
                                      await Clipboard.getData('text/plain');
                                  _wifController.text = data!.text!.trim();
                                },
                                icon: Icon(
                                  Icons.paste_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            minLines: 4,
                            maxLines: 4,
                          ),
                          if (!kIsWeb) const SizedBox(height: 10),
                          if (!kIsWeb)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PeerButton(
                                  action: () => createQrScanner('priv'),
                                  text: AppLocalizations.instance
                                      .translate('paperwallet_step_2_text'),
                                  small: true,
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PeerButton(
                                action: () {
                                  _formKey.currentState!.save();
                                  _formKey.currentState!.validate();
                                },
                                text: AppLocalizations.instance
                                    .translate('import_button'),
                                small: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.instance
                                .translate('import_wif_hint'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
