import 'package:flutter/material.dart';
import '../../core/app_constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double? borderWidth;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      margin: margin ?? const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: borderWidth ?? 1.0)
            : BorderSide.none,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.paddingLarge),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: card,
      );
    }

    return card;
  }
}