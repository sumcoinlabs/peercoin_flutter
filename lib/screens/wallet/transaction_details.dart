import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sumcoin/providers/connection_provider.dart';
import 'package:sumcoin/widgets/double_tab_to_clipboard.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../widgets/banner_ad_widget.dart';
import '../../widgets/native_ad_widget.dart';

import '../../models/available_coins.dart';
import '../../models/hive/coin_wallet.dart';
import '../../models/hive/wallet_transaction.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/buttons.dart';
import '../../widgets/service_container.dart';

class TransactionDetails extends StatelessWidget {
  const TransactionDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final WalletTransaction tx = args['tx'];
    final CoinWallet coinWallet = args['wallet'];
    final baseUrl =
        '${AvailableCoins.getSpecificCoin(coinWallet.name).explorerUrl}/tx/';
    final decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: coinWallet.name,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('transaction_details'),
        ),
      ),
      body: Align(
        child: PeerContainer(
          noSpacers: true,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('id'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(tx.txid),
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('time'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    tx.timestamp != 0
                        ? DateFormat().format(
                            DateTime.fromMillisecondsSinceEpoch(
                              tx.timestamp * 1000,
                            ),
                          )
                        : AppLocalizations.instance.translate('unconfirmed'),
                  ),
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_value'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    '${tx.value / decimalProduct} ${coinWallet.letterCode}',
                  ),
                ],
              ),
              tx.direction == 'out'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(
                          AppLocalizations.instance.translate('tx_fee'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(
                          '${tx.fee / decimalProduct} ${coinWallet.letterCode}',
                        ),
                      ],
                    )
                  : Container(),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_recipients'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...renderRecipients(
                    tx: tx,
                    letterCode: coinWallet.letterCode,
                    decimalProduct: decimalProduct,
                  ),
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_direction'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(tx.direction),
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_confirmations'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    tx.confirmations == -1
                        ? AppLocalizations.instance.translate('tx_rejected')
                        : tx.confirmations.toString(),
                  ),
                ],
              ),
              tx.opReturn.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(
                          AppLocalizations.instance.translate(
                            'send_op_return',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(tx.opReturn),
                      ],
                    )
                  : const SizedBox(),
              tx.confirmations == -1
                  ? ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        AppLocalizations.instance.translate('tx_show_hex'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      children: [
                        DoubleTabToClipboard(
                          clipBoardData: tx.broadcastHex,
                          withHintText: true,
                          child: SelectableText(
                            tx.broadcastHex,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              tx.confirmations == -1
                  ? Center(
                      child: PeerButton(
                        action: () {
                          Provider.of<ConnectionProvider>(
                            context,
                            listen: false,
                          ).broadcastTransaction(
                            tx.broadcastHex,
                            tx.txid,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.instance.translate(
                                  'tx_retry_snack',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        text: AppLocalizations.instance.translate(
                          'tx_retry_broadcast',
                        ),
                      ),
                    )
                  : Center(
                      child: PeerButton(
                        action: () => _launchURL(baseUrl + tx.txid),
                        text: AppLocalizations.instance.translate(
                          'tx_view_in_explorer',
                        ),
                      ),
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
    );
  }

  List<Widget> renderRecipients({
    required WalletTransaction tx,
    required String letterCode,
    required int decimalProduct,
  }) {
    List<Widget> list = [];

    if (tx.recipients.isEmpty) {
      list.add(
        renderRow(tx.address, tx.value / decimalProduct, letterCode),
      );
    }
    tx.recipients.forEach(
      (addr, value) => list.add(
        renderRow(addr, value / decimalProduct, letterCode),
      ),
    );
    return list;
  }

  Widget renderRow(String addr, double value, String letterCode) {
    return Row(
      key: Key(addr),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: DoubleTabToClipboard(
            clipBoardData: addr,
            withHintText: false,
            child: Text(
              addr,
              style: const TextStyle(
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Flexible(
          child: Text('$value $letterCode'),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    await canLaunchUrlString(url)
        ? await launchUrlString(
            url,
          )
        : throw 'Could not launch $url';
  }
}
