import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../tools/app_localizations.dart';
import '../../../tools/share_wrapper.dart';
import '../../buttons.dart';
import '../../double_tab_to_clipboard.dart';

class WalletHomeQr extends StatelessWidget {
  final String _unusedAddress;
  const WalletHomeQr(this._unusedAddress, {Key? key}) : super(key: key);

  static void showQrDialog(
    BuildContext context,
    String address, [
    bool hideShareButton = false,
  ]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.33,
                    width: MediaQuery.of(context).size.width * 1,
                    child: Center(
                      child: Container(
                        color: Colors.white, // Set background color to white
                        child: QrImageView(
                          data: address,
                        ),
                      ),
                    ),
                  ),
                  if (!hideShareButton)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        child: DoubleTabToClipboard(
                          withHintText: true, // Provide a value for withHintText
                          clipBoardData: address,
                          child: SelectableText(
                            address,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  if (!hideShareButton)
                    PeerButtonBorder(
                      action: () => ShareWrapper.share(
                        context: context,
                        message: address,
                        popNavigator: true,
                      ),
                      text: AppLocalizations.instance.translate('receive_share'),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var inkWell = InkWell(
      onTap: () => showQrDialog(context, _unusedAddress),
      child: QrImageView(
        data: _unusedAddress,
        size: 60.0,
        padding: const EdgeInsets.all(1),
      ),
    );
    return _unusedAddress.isEmpty
        ? const SizedBox(height: 60, width: 60)
        : inkWell;
  }
}
