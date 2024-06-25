import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  static Future<void> clearData() {
    return Future.delayed(const Duration(seconds: 0));
  }

  static void reloadWindow() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
} /* This dummy is required to prevent build time errors since dart:html is not availble on native devices */
