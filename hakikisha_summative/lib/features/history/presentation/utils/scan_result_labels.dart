import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';

/// The translated word for a scan's result.
String resultLabel(AppLocalizations l10n, String result) {
  switch (result.toLowerCase()) {
    case 'genuine':
      return l10n.historyGenuine;
    case 'flagged':
      return l10n.historyFlagged;
    default:
      return l10n.historyNotFound;
  }
}

/// The translated word for how a scan was made.
String methodLabel(AppLocalizations l10n, String method) {
  switch (method) {
    case 'camera':
      return l10n.historyMethodCamera;
    case 'manual':
      return l10n.historyMethodManual;
    case 'upload':
      return l10n.historyMethodUpload;
    default:
      return method;
  }
}

/// Green for genuine, red for flagged, grey for anything else.
Color resultColor(BuildContext context, String result) {
  final palette = context.palette;
  switch (result.toLowerCase()) {
    case 'genuine':
      return palette.success;
    case 'flagged':
      return palette.danger;
    default:
      return palette.textMuted;
  }
}
