import 'package:flutter/material.dart';

import '../../../../core/l10n/gen/app_localizations.dart';
import '../../../../core/widgets/placeholder_page.dart';

/// Tab Cài đặt — tài khoản, chia sẻ của tôi, quyền riêng tư (làm ở M5).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderPage(title: AppLocalizations.of(context).tabSettings);
}
