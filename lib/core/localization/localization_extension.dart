import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/localization/app_localizations.dart';

/// Extension to easily access localization in widgets
/// Usage: context.l10n.home
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
