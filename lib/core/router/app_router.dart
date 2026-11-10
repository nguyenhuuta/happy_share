import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/family/presentation/pages/family_page.dart';
import '../../features/journey/presentation/pages/journey_page.dart';
import '../../features/members/presentation/pages/members_page.dart';
import '../../features/places/presentation/pages/places_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../l10n/gen/app_localizations.dart';
import '../session/app_session_cubit.dart';
import '../widgets/placeholder_page.dart';
import 'app_routes.dart';
import 'session_redirect.dart';

export 'app_routes.dart';

/// Biến luồng trạng thái của [AppSessionCubit] thành `Listenable` để GoRouter chạy lại `redirect`.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(AppSessionCubit session) {
    _sub = session.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// [session] có thì điều hướng theo [SessionStatus] (đăng nhập → tạo/tham gia gia đình → consent → shell).
/// Không có [session] (test shell) thì không redirect.
GoRouter createAppRouter({AppSessionCubit? session}) {
  final listenable = session == null ? null : _SessionListenable(session);
  return GoRouter(
    initialLocation: session == null ? AppRoutes.family : AppRoutes.splash,
    refreshListenable: listenable,
    redirect: session == null
        ? null
        : (context, state) =>
              sessionRedirect(session.state.status, state.uri.path),
    routes: [
      // Các màn UI thật (Stitch) thay PlaceholderPage khi có thiết kế.
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, _) =>
            PlaceholderPage(title: AppLocalizations.of(context).appName),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, _) =>
            PlaceholderPage(title: AppLocalizations.of(context).pageLogin),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, _) =>
            PlaceholderPage(title: AppLocalizations.of(context).pageRegister),
      ),
      GoRoute(
        path: AppRoutes.familySetup,
        builder: (context, _) => PlaceholderPage(
          title: AppLocalizations.of(context).pageFamilySetup,
        ),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, _) => PlaceholderPage(
              title: AppLocalizations.of(context).pageCreateFamily,
            ),
          ),
          GoRoute(
            path: 'join',
            builder: (context, _) => PlaceholderPage(
              title: AppLocalizations.of(context).pageJoinFamily,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.consentIntro,
        builder: (context, _) => PlaceholderPage(
          title: AppLocalizations.of(context).pageConsentIntro,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabShell(shell: shell),
        branches: [
          _branch(AppRoutes.family, (_, _) => const FamilyPage()),
          _branch(AppRoutes.journey, (_, _) => const JourneyPage()),
          _branch(AppRoutes.places, (_, _) => const PlacesPage()),
          _branch(AppRoutes.members, (_, _) => const MembersPage()),
          _branch(AppRoutes.settings, (_, _) => const SettingsPage()),
        ],
      ),
    ],
  );
}

StatefulShellBranch _branch(
  String path,
  Widget Function(BuildContext, GoRouterState) builder,
) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: builder)],
);

class _TabShell extends StatelessWidget {
  const _TabShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.family_restroom_outlined),
            selectedIcon: const Icon(Icons.family_restroom),
            label: l10n.tabFamily,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timeline_outlined),
            selectedIcon: const Icon(Icons.timeline),
            label: l10n.tabJourney,
          ),
          NavigationDestination(
            icon: const Icon(Icons.place_outlined),
            selectedIcon: const Icon(Icons.place),
            label: l10n.tabPlaces,
          ),
          NavigationDestination(
            icon: const Icon(Icons.group_outlined),
            selectedIcon: const Icon(Icons.group),
            label: l10n.tabMembers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
