import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Gradient gradient;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  const GradientButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    required this.gradient,
    this.width = double.infinity,
    this.height = 48.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = textStyle ??
        TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );

    return SizedBox(
      width: width,
      height: height,
      child: Opacity(
        opacity: onPressed == null ? 0.6 : 1.0,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: borderRadius,
              boxShadow: [
                if (onPressed != null)
                  BoxShadow(
                    color: Colors.black.withValues(),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
              ],
            ),
            child: Padding(
              padding: padding,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        text,
                        style: effectiveTextStyle,
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
