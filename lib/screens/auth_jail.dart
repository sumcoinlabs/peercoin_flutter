import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';
import '../providers/encrypted_box_provider.dart';
import '../tools/app_localizations.dart';
import '../tools/app_routes.dart';
import '../tools/auth.dart';

class AuthJailScreen extends StatefulWidget {
  @override
  State<AuthJailScreen> createState() => _AuthJailState();

  final bool jailedFromHome;
  const AuthJailScreen({
    super.key,
    this.jailedFromHome = false,
  });
}

class _AuthJailState extends State<AuthJailScreen> {
  late Timer _timer;
  int _lockCountdown = 0;
  bool _initial = true;
  bool _jailedFromRoute = false;

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_lockCountdown == 0) {
          _timer.cancel();
          onTimerEnd();
        } else {
          setState(() {
            _lockCountdown--;
          });
        }
      },
    );
  }

  void onTimerEnd() async {
    final appSettings = context.read<AppSettingsProvider>();
    await appSettings.init();
    if (mounted) {
      await Auth.requireAuth(
        context: context,
        biometricsAllowed: appSettings.biometricsAllowed,
        callback: () async {
          final encryptedStorage = context.read<EncryptedBoxProvider>();
          final navigator = Navigator.of(context);
          await encryptedStorage.setFailedAuths(0);
          if (widget.jailedFromHome == true || _jailedFromRoute == true) {
            await navigator.pushReplacementNamed(Routes.walletList);
          } else {
            navigator.popUntil((route) => route.isFirst);
          }
        },
        canCancel: false,
        jailedFromHome: widget.jailedFromHome,
      );
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _startTimer();
      final encryptedStorage = context.read<EncryptedBoxProvider>();
      final modalRoute = ModalRoute.of(context)!;
      final failedAuths = await encryptedStorage.failedAuths;
      _lockCountdown = 10 + (failedAuths * 10);

      //increase number of failed auths
      await encryptedStorage.setFailedAuths(failedAuths + 1);

      //check if jailedFromHome came again through route
      if (widget.jailedFromHome == false) {
        final jailedFromRoute = modalRoute.settings.arguments as bool?;
        if (jailedFromRoute == true) _jailedFromRoute = true;
      }

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          color: Theme.of(context).primaryColor,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.instance.translate('jail_heading'),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  _lockCountdown.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.instance.translate('jail_countdown'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const LinearProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
