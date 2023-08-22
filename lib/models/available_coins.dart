import 'dart:math';

import 'package:coinslib/coinslib.dart';
import 'coin.dart';

class AvailableCoins {
  static final Map<String, Coin> _availableCoinList = {
    'sumcoin': Coin(
      name: 'sumcoin',
      displayName: 'Sumcoin',
      uriCode: 'sumcoin',
      letterCode: 'SUM',
      iconPath: 'assets/icon/sum-icon-white-64.png',
      iconPathTransparent: 'assets/icon/sum-icon-white-64.png',
      networkType: NetworkType(
        messagePrefix: 'Sumcoin Signed Message:\n',
        bech32: 'sum',
        bip32: Bip32Type(public: 0xF588B21F, private: 0xF588ADE5),
        pubKeyHash: 0x3F,
        scriptHash: 0x7D,
        wif: 0xBB,
        opreturnSize: 256,
      ),
      fractions: 6,
      minimumTxValue: 1000,
      fixedFee: true,
      fixedFeePerKb: 0.01,
      explorerUrl: 'https://sumcoinexplorer.com',
      genesisHash:
      '000000f40beaad5804ce621cca107c37dccd119e887625fe79fe0f4e161f6219',
      txVersion: 3,
      electrumRequiredProtocol: 1.4,
      electrumServers: [
        'ssl://sumpos.electrum-sum.org:50002',
        //      'wss://sumpos.electrum-sum.org:50004',
      ],
    ), /*
    'sumcoin-pow': Coin(
      name: 'sumcoin-pow',
      displayName: 'Sumcoin Chain 2',
      uriCode: 'sumcoin-pow',
      letterCode: 'SUM-POW',
      iconPath: 'assets/icon/sum-icon-white-64.png',
      iconPathTransparent: 'assets/icon/sum-icon-white-64.png',
      networkType: NetworkType(
        messagePrefix: 'Sumcoin POW Signed Message:\n',
        bech32: 'sumpow',
        bip32: Bip32Type(public: 0x0488b41c, private: 0x0488abe6),
        pubKeyHash: 0x3F,
        scriptHash: 0x05,
        wif: 0xBF,
        opreturnSize: 100,
      ),
      fractions: 8,
      minimumTxValue: 10000,
      fixedFee: true,
      fixedFeePerKb: 0.01,
      explorerUrl: 'https://insight.sumcore.org',
      genesisHash:
      '37d4696c5072cd012f3b7c651e5ce56a1383577e4edacc2d289ec9b25eebfd5e',
      txVersion: 1,
      electrumRequiredProtocol: 1.4,
      electrumServers: [
        'ssl://sum2.electrum-sum.org:50002',
        //      'wss://sum1.electrum-sum.org:50004',
      ],
    ),
    'sumcoinTestnet': Coin(
      name: 'sumcoinTestnet',
      displayName: 'Sumcoin Chain 1',
      uriCode: 'sumcoin',
      letterCode: 'SUM',
      iconPath: 'assets/icon/sum-icon-48.png',
      iconPathTransparent: 'assets/icon/sum-icon-white-48.png',
      networkType: NetworkType(
        messagePrefix: 'Sumcoin Signed Message:\n',
        bech32: 'tpc',
        bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
        pubKeyHash: 0x6f,
        scriptHash: 0xc4,
        wif: 0xef,
        opreturnSize: 256,
      ),
      fixedFee: true,
      fractions: 6,
      minimumTxValue: 10000,
      fixedFeePerKb: 0.01,
      explorerUrl: 'https://tblockbook.sumcoin.org',
      genesisHash:
          '00000001f757bb737f6596503e17cd17b0658ce630cc727c0cca81aec47c9f06',
      txVersion: 3,
      electrumRequiredProtocol: 1.4,
      electrumServers: [
        'wss://testnet-electrum.sumcoinexplorer.net:50009',
        'wss://allingas.sumcoinexplorer.net:50009',
      ],
    ), */
  };

  static Map<String, Coin> get availableCoins {
    return _availableCoinList;
  }

  static Coin getSpecificCoin(String identifier) {
    return _availableCoinList[identifier]!;
  }

  static int getDecimalProduct({required String identifier}) {
    return pow(
      10,
      getSpecificCoin(identifier).fractions,
    ).toInt();
  }
}
