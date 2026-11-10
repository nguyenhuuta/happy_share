import 'package:flutter/material.dart';

import '../../../../core/l10n/gen/app_localizations.dart';
import '../../../../core/widgets/placeholder_page.dart';

/// Tab Địa điểm — CRUD Place trên bản đồ (làm ở M4).
class PlacesPage extends StatelessWidget {
  const PlacesPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderPage(title: AppLocalizations.of(context).tabPlaces);
}
