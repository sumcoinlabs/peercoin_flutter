import 'dart:math';

import 'package:sumcoinlib_flutter/sumcoinlib_flutter.dart';

import 'coin.dart';

class AvailableCoins {
  static final Map<String, Coin> _availableCoinList = {
    'sumcoin': Coin(
      name: 'sumcoin',
      displayName: 'Sumcoin',
      uriCode: 'sumcoin',
      letterCode: 'SUM',
      iconPath: 'assets/icon/sum-icon-48.png',
      iconPathTransparent: 'assets/icon/sum-icon-white-48.png',
      networkType: Network.mainnet,
      opreturnSize: 256,
      fractions: 6,
      minimumTxValue: 10000,
      fixedFee: true,
      fixedFeePerKb: 0.01,
      explorerUrl: 'https://sumexplorer.com',
      genesisHash:
          '000000f40beaad5804ce621cca107c37dccd119e887625fe79fe0f4e161f6219',
      txVersion: 3,
      electrumRequiredProtocol: 1.4,
      electrumServers: [
      'ssl://sumpos.electrum-sum.org:50002',
      'ssl://sumpos2.electrum-sum.org:50002',
      ],
      marismaServers: [
        ('marisma.ppc.lol', 8443),
      ],
    ),
  /*  'peercoinTestnet': Coin(
      name: 'peercoinTestnet',
      displayName: 'Sumcoin Testnet',
      uriCode: 'sumcoin',
      letterCode: 'tSUM',
      iconPath: 'assets/icon/sum-icon-48-grey.png',
      iconPathTransparent: 'assets/icon/sum-icon-48-grey.png',
      networkType: Network.testnet,
      opreturnSize: 256,
      fixedFee: true,
      fractions: 6,
      minimumTxValue: 10000,
      fixedFeePerKb: 0.01,
      explorerUrl: 'https://tblockbook.sumcoin.net',
      genesisHash:
          '00000001f757bb737f6596503e17cd17b0658ce630cc727c0cca81aec47c9f06',
      txVersion: 3,
      electrumRequiredProtocol: 1.4,
      electrumServers: [
        'wss://testnet-electrum.peercoinexplorer.net:50009',
        'wss://allingas.peercoinexplorer.net:50009',
      ],
      marismaServers: [
        ('test-marisma.ppc.lol', 2096),
      ],
    ), */
  };

  static Map<String, Coin> get availableCoins {
    return _availableCoinList;
  }

  static Coin getSpecificCoin(String identifier) {
    final coin = identifier.split('_').first;
    if (_availableCoinList.containsKey(coin)) {
      return _availableCoinList[coin]!;
    } else {
      throw Exception('Coin not found');
    }
  }

  static int getDecimalProduct({
    required String identifier,
  }) {
    return pow(
      10,
      getSpecificCoin(identifier).fractions,
    ).toInt();
  }
}
