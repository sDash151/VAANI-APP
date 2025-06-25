import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SignPlayer extends StatefulWidget {
  final String signLabel; // e.g., "नमस्ते", "धन्यवाद"
  final bool autoplay;
  final double size;

  const SignPlayer({
    super.key,
    required this.signLabel,
    this.autoplay = true,
    this.size = 200,
  });

  @override
  State<SignPlayer> createState() => _SignPlayerState();
}

class _SignPlayerState extends State<SignPlayer> {
  String? _animationAsset;

  @override
  void initState() {
    super.initState();
    _animationAsset = _getAnimationAsset(widget.signLabel);
  }

  @override
  void didUpdateWidget(covariant SignPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.signLabel != oldWidget.signLabel) {
      setState(() {
        _animationAsset = _getAnimationAsset(widget.signLabel);
      });
    }
  }

  String _getAnimationAsset(String signLabel) {
    switch (signLabel) {
      case 'नमस्ते':
        return 'assets/animations/namaste.json';
      case 'धन्यवाद':
        return 'assets/animations/thankyou.json';
      // Add more mappings as needed
      default:
        return 'assets/animations/hello.json'; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animationAsset == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        _animationAsset!,
        repeat: true,
        animate: widget.autoplay,
      ),
    );
  }
}
