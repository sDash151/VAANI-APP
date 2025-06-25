import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

/// A widget that wraps its [child] and provides haptic feedback
/// (via the device vibrator) when tapped or long-pressed, then
/// forwards the gesture to the provided callbacks.
class VibrationFeedbackWidget extends StatelessWidget {
  /// Called when the child is tapped.
  final VoidCallback? onTap;

  /// Called when the child is long-pressed.
  final VoidCallback? onLongPress;

  /// The widget subtree to display.
  final Widget child;

  /// The vibration duration (in milliseconds) for tap feedback.
  final int tapVibrationDuration;

  /// The vibration duration (in milliseconds) for long-press feedback.
  final int longPressVibrationDuration;

  const VibrationFeedbackWidget({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.tapVibrationDuration = 50,
    this.longPressVibrationDuration = 100,
  }) : super(key: key);

  Future<void> _vibrate(int duration) async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _vibrate(tapVibrationDuration);
        if (onTap != null) {
          onTap!();
        }
      },
      onLongPress: () async {
        await _vibrate(longPressVibrationDuration);
        if (onLongPress != null) {
          onLongPress!();
        }
      },
      child: child,
    );
  }
}
