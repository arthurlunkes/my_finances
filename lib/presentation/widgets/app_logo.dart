import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final String? assetPath;

  const AppLogo({
    super.key,
    this.size = 36,
    this.showText = false,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final double circleSize = size;
    Widget circle;
    if (assetPath != null) {
      circle = ClipOval(
        child: Image.asset(
          assetPath!,
          width: circleSize,
          height: circleSize,
          fit: BoxFit.cover,
        ),
      );
    } else {
      circle = Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'MF',
          style: TextStyle(
            color: Colors.white,
            fontSize: (circleSize * 0.45).clamp(12, 20),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'My Finances',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
