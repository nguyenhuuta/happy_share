import 'package:flutter/material.dart';

import '../../../../core/l10n/gen/app_localizations.dart';
import '../../../../core/widgets/placeholder_page.dart';

/// Tab Hành trình — timeline visit/travel/gap + bản đồ (làm ở M4).
class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderPage(title: AppLocalizations.of(context).tabJourney);
}
