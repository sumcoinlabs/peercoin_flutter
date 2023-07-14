import 'package:flutter/material.dart';

class SpinningSumcoinIcon extends StatefulWidget {
  const SpinningSumcoinIcon({
    super.key,
  });

  @override
  State<SpinningSumcoinIcon> createState() => _SpinningSumcoinIconState();
}

class _SpinningSumcoinIconState extends State<SpinningSumcoinIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    //init animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
      child: Image.asset(
        'assets/icon/sum-icon-white-256.png',
        height: 80,
      ),
    );
  }
}
