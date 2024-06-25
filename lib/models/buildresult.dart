import 'hive/wallet_utxo.dart';

class BuildResult {
  final int fee;
  final String hex;
  final Map<String, int> recipients;
  final int totalAmount;
  final String id;
  final int destroyedChange;
  final String opReturn;
  final bool neededChange;
  final bool allRecipientOutPutsAreZero;
  final bool feesHaveBeenDeductedFromRecipient;
  final List<WalletUtxo> inputTx;

  BuildResult({
    required this.fee,
    required this.hex,
    required this.recipients,
    required this.totalAmount,
    required this.id,
    required this.destroyedChange,
    required this.opReturn,
    required this.neededChange,
    required this.allRecipientOutPutsAreZero,
    required this.feesHaveBeenDeductedFromRecipient,
    required this.inputTx,
  });
}
