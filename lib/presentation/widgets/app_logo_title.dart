import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';

class AppLogoTitle extends StatelessWidget {
  final double logoSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final bool showSubtitle;

  const AppLogoTitle({
    super.key,
    this.logoSize = 40,
    this.titleFontSize = 20,
    this.subtitleFontSize = 12,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo with subtle animation
        Hero(
          tag: 'app_logo',
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: logoSize,
              width: logoSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // App name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAMELA',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
                letterSpacing: 1.5,
                height: 1.2,
              ),
            ),
            if (showSubtitle)
              Text(
                'CRUISE',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryGreen.withOpacity(0.7),
                  letterSpacing: 2.5,
                  height: 1,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// Alternative: Horizontal layout
class AppLogoTitleHorizontal extends StatelessWidget {
  final double logoSize;
  final double fontSize;

  const AppLogoTitleHorizontal({
    super.key,
    this.logoSize = 36,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: logoSize,
          width: logoSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'PAMELA ',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 1.2,
                ),
              ),
              TextSpan(
                text: 'CRUISE',
                style: TextStyle(
                  fontSize: fontSize * 0.8,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryGreen.withOpacity(0.8),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Alternative: Compact version for small spaces
class AppLogoTitleCompact extends StatelessWidget {
  final double size;

  const AppLogoTitleCompact({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: size,
          width: size,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 6),
        Text(
          'PAMELA',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
