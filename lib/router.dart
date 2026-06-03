import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'controllers/auth_controller.dart';
import 'views/auth/login_screen.dart';
import 'views/deposits/deposit_detail_screen.dart';
import 'views/deposits/deposits_screen.dart';
import 'views/home/home_shell.dart';
import 'views/inspections/inspection_detail_screen.dart';
import 'views/inspections/inspections_screen.dart';
import 'views/maintenance/maintenance_detail_screen.dart';
import 'views/maintenance/maintenance_screen.dart';
import 'views/maintenance/submit_request_screen.dart';
import 'views/messages/conversations_screen.dart';
import 'views/messages/thread_screen.dart';
import 'views/notifications/notifications_screen.dart';
import 'views/shared/widgets/loading_spinner.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/home/deposits',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),

      // Shell wraps bottom-nav tabs, keeps them alive while switching
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/deposits',
              builder: (_, _) => const DepositsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/maintenance',
              builder: (_, _) => const MaintenanceScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/messages',
              builder: (_, _) => const ConversationsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home/notifications',
              builder: (_, _) => const NotificationsScreen(),
            ),
          ]),
        ],
      ),

      // Detail routes (full-screen, outside shell)
      GoRoute(
        path: '/deposits/:id',
        builder: (_, state) =>
            DepositDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/inspections',
        builder: (_, _) => const InspectionsScreen(),
      ),
      GoRoute(
        path: '/inspections/:id',
        builder: (_, state) =>
            InspectionDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/maintenance/new',
        builder: (_, _) => const SubmitRequestScreen(),
      ),
      GoRoute(
        path: '/maintenance/:id',
        builder: (_, state) =>
            MaintenanceDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/messages/:id',
        builder: (_, state) =>
            ThreadScreen(id: int.parse(state.pathParameters['id']!)),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

// ---------------------------------------------------------------------------
// Router notifier — bridges Riverpod auth state with GoRouter's Listenable API
// ---------------------------------------------------------------------------

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(authControllerProvider, (_, next) {
      _isLoading = next.isLoading;
      _isAuthenticated = next.valueOrNull?.isAuthenticated ?? false;
      notifyListeners();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    if (_isLoading) return null;

    final onLogin = state.matchedLocation == '/login';

    if (!_isAuthenticated && !onLogin) return '/login';
    if (_isAuthenticated && onLogin) return '/home/deposits';

    return null;
  }
}

/// Splash shown while the router resolves the initial auth state.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const FullScreenLoader();
}
