import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/events/domain/event_item.dart';
import '../../features/events/presentation/events_page.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/home/presentation/attendance_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/inbox/presentation/inbox_pages.dart';
import '../../features/leaves/presentation/leaves_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/punch/presentation/punch_error_page.dart';
import '../../features/punch/presentation/punch_location_page.dart';
import '../../features/punch/presentation/punch_photo_page.dart';
import '../../features/punch/presentation/punch_providers.dart';
import '../../features/punch/presentation/punch_result_page.dart';
import '../config/app_config.dart';
import '../design/gallery_page.dart';
import '../mock/scenario_page.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loc = state.matchedLocation;
      if (session.isLoading || session.hasError) {
        return loc == '/splash' ? null : '/splash';
      }
      final loggedIn = session.value != null;
      if (!loggedIn) return loc == '/login' ? null : '/login';
      if (loc == '/login' || loc == '/splash') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/attendance',
                builder: (_, _) => const AttendancePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaves',
                builder: (_, state) => LeavesPage(
                  category: state.uri.queryParameters['category'],
                  typeCode: state.uri.queryParameters['type'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/history', builder: (_, _) => const HistoryPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/punch/in',
        builder: (_, _) =>
            const PunchLocationPage(target: PunchTarget(PunchKind.checkIn)),
      ),
      GoRoute(
        path: '/punch/out',
        builder: (_, _) =>
            const PunchLocationPage(target: PunchTarget(PunchKind.checkOut)),
      ),
      GoRoute(
        path: '/punch/event',
        redirect: (_, state) => state.extra is EventItem ? null : '/events',
        builder: (_, state) =>
            PunchLocationPage(target: EventTarget(state.extra! as EventItem)),
      ),
      GoRoute(path: '/punch/photo', builder: (_, _) => const PunchPhotoPage()),
      GoRoute(
        path: '/punch/result',
        builder: (_, _) => const PunchResultPage(),
      ),
      GoRoute(path: '/punch/error', builder: (_, _) => const PunchErrorPage()),
      GoRoute(path: '/events', builder: (_, _) => const EventsPage()),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsPage(),
      ),
      GoRoute(path: '/approvals', builder: (_, _) => const ApprovalsPage()),
      if (AppConfig.debugTools) ...[
        GoRoute(path: '/debug/galeri', builder: (_, _) => const GalleryPage()),
        GoRoute(
          path: '/debug/skenario',
          builder: (_, _) => const ScenarioPage(),
        ),
      ],
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
