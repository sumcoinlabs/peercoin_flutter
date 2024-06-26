import 'package:sumcoinlib_flutter/sumcoinlib_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumcoin/models/available_coins.dart';
import 'package:sumcoin/tools/validators.dart';

void main() async {
  //init coinlib
  await loadSumCoinlib();

  group('validators', () {
    final network = AvailableCoins.getSpecificCoin('sumcoin').networkType;
    test('validateAddress', () {
      assert(
        validateAddress('PXDR4KZn2WdTocNx1GPJXR96PfzZBvWqKQ', network) == true,
      );
      assert(
        validateAddress('PXDR4KZn2WdTocNx1GPJXR96PfzZBvWqKq', network) == false,
      );
    });

    test('validateWIFPrivKey', () {
      assert(
        validateWIFPrivKey(
              'UBhubKxzjdkdPEwMX83nKS1RNgJCWBXFoE7pDrXaQJA3MjeFL8cf',
            ) ==
            true,
      );
      assert(
        validateWIFPrivKey(
              'UBhubKxzjdkdPEwMX83nKS1RNgJCWBXFoE7pDrXaQJA3MjeFL8cF',
            ) ==
            false,
      );
    });
  });
}
