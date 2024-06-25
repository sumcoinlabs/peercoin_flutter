import 'dart:async';

import 'package:flutter/material.dart';

class WalletBalancePrice extends StatefulWidget {
  final Text valueInFiat;
  final Text fiatCoinValue;
  const WalletBalancePrice({
    super.key,
    required this.valueInFiat,
    required this.fiatCoinValue,
  });

  @override
  State<WalletBalancePrice> createState() => _WalletBalancePriceState();
}

class _WalletBalancePriceState extends State<WalletBalancePrice> {
  late Widget _animatedWidget;
  bool _showFiatCoinValue = true;
  late Timer _timer;

  @override
  void initState() {
    _animatedWidget = _fiatCoinValue();
    Future.delayed(
      const Duration(seconds: 1),
      _widgetIntervalGiver(),
    );

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        _widgetIntervalGiver();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _valueInFiat() =>
      SizedBox(key: const Key('valueInFiat'), child: widget.valueInFiat);

  Widget _fiatCoinValue() =>
      SizedBox(key: const Key('fiatCoinValue'), child: widget.fiatCoinValue);

  _widgetIntervalGiver() {
    setState(() {
      _animatedWidget = _showFiatCoinValue ? _fiatCoinValue() : _valueInFiat();
      _showFiatCoinValue = !_showFiatCoinValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _animatedWidget,
    );
  }
}
