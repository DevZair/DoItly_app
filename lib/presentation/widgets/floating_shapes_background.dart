import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FloatingShapesBackground extends StatelessWidget {
  const FloatingShapesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.background),
          child: Stack(
            children: const [
              _NeonBlob(
                size: 260,
                top: -120,
                left: -60,
                color: AppColors.primary,
              ),
              _NeonBlob(
                size: 200,
                top: 90,
                right: -40,
                color: AppColors.accent,
              ),
              _NeonBlob(
                size: 240,
                bottom: -80,
                left: 40,
                color: AppColors.glow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeonBlob extends StatelessWidget {
  const _NeonBlob({
    required this.size,
    required this.color,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  final double size;
  final Color color;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final glow = color.withValues(alpha: 0.27);
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          boxShadow: [
            BoxShadow(color: glow, blurRadius: 120, spreadRadius: 80),
          ],
        ),
      ),
    );
  }
}
