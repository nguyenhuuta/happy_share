import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';

/// Màn tạm cho tab chưa làm (M0). Thay bằng màn thật ở milestone tương ứng.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          l10n.emptyComingSoon,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
