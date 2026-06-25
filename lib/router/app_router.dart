import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/role_select_screen.dart';
import '../screens/browse/home_screen.dart';
import '../screens/browse/search_screen.dart';
import '../screens/browse/item_detail_screen.dart';
import '../screens/listing/create_listing_screen.dart';
import '../screens/listing/my_listings_screen.dart';
import '../screens/listing/edit_listing_screen.dart';
import '../screens/booking/booking_form_screen.dart';
import '../screens/booking/payment_screen.dart';
import '../screens/booking/history_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_room_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';

part 'app_router.g.dart';

// NOTE: jalankan `dart run build_runner build --delete-conflicting-outputs`
// untuk men-generate `app_router.g.dart`.

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

const _authRoutes = ['/login', '/register', '/otp'];

/// Urutan branch TETAP (index ini dipakai di [_RoleAwareScaffold]):
/// 0 home, 1 search, 2 listing/my, 3 history, 4 chat, 5 profile.
///
/// `category_screen.dart` ada di folder screens/browse/ tapi TIDAK ada di
/// daftar path Prompt #1 — sengaja tidak didaftarkan sebagai route di sini.
/// Tambahkan rute untuknya (mis. `/category/:slug`) di prompt berikutnya
/// kalau memang dibutuhkan.
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  // GoRouter dibuat SEKALI (keepAlive) supaya navigation stack tidak reset
  // setiap auth/role state berubah. `refreshListenable` yang memberitahu
  // router untuk re-evaluate `redirect`, bukan rebuild seluruh GoRouter.
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final loggedIn = ref.read(currentSessionProvider) != null;
      final loc = state.matchedLocation;
      final onAuthRoute = _authRoutes.contains(loc);

      // Auth state awal belum settle sama sekali → jangan redirect dulu.
      if (authState.isLoading && !authState.hasValue) return null;

      if (!loggedIn) {
        return onAuthRoute ? null : '/login';
      }

      final roleAsync = ref.read(currentUserRoleProvider);
      // Sudah login tapi role masih di-fetch → tunggu, jangan redirect dulu.
      if (roleAsync.isLoading && !roleAsync.hasValue) return null;

      final role = roleAsync.value;
      if (role == null) {
        return loc == '/role-select' ? null : '/role-select';
      }

      if (onAuthRoute || loc == '/role-select') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(path: '/role-select', builder: (_, __) => const RoleSelectScreen()),
      GoRoute(
        path: '/item/:id',
        builder: (_, state) => ItemDetailScreen(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/listing/create',
        builder: (_, __) => const CreateListingScreen(),
      ),
      GoRoute(
        path: '/listing/edit/:id',
        builder: (_, state) => EditListingScreen(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/:itemId',
        builder: (_, state) =>
            BookingFormScreen(itemId: state.pathParameters['itemId']!),
      ),
      GoRoute(
        path: '/payment/:bookingId',
        builder: (_, state) =>
            PaymentScreen(bookingId: state.pathParameters['bookingId']!),
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatRoomScreen(
            otherUserId: state.pathParameters['userId']!,
            bookingId: state.uri.queryParameters['bookingId']!,
            otherUserName: extra?['otherUserName'] as String?,
            otherUserAvatar: extra?['otherUserAvatar'] as String?,
            itemTitle: extra?['itemTitle'] as String?,
          );
        },
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _RoleAwareScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (_, state) => SearchScreen(
                  categoryId: state.uri.queryParameters['categoryId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/listing/my', builder: (_, __) => const MyListingsScreen())
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/history', builder: (_, __) => const HistoryScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/chat', builder: (_, __) => const ChatListScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())],
          ),
        ],
      ),
    ],
  );
}

/// Adapter kecil: dengarkan provider auth/role lewat `ref.listen` (side
/// effect, BUKAN `ref.watch` di body `appRouter`) lalu panggil
/// `notifyListeners()` supaya GoRouter re-run `redirect` tanpa GoRouter itu
/// sendiri di-rebuild dari nol.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
    ref.listen(currentUserRoleProvider, (_, __) => notifyListeners());
  }
}

/// Scaffold + bottom nav yang tampilannya beda per role:
/// - Penyewa : Home, Cari, Riwayat Sewa, Chat, Profil
/// - Pemilik : Dashboard, Barangku, Riwayat, Chat, Profil
///
/// Branch index TETAP ada 6 (lihat komentar di atas [appRouter]); per role
/// hanya 5 yang ditampilkan di nav bar (branch ke-1 "search" disembunyikan
/// untuk Pemilik, branch ke-2 "listing/my" disembunyikan untuk Penyewa).
/// Branch yang disembunyikan tetap technically reachable lewat path
/// langsung, hanya tidak muncul sebagai tab.
class _RoleAwareScaffold extends ConsumerWidget {
  const _RoleAwareScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider).value;
    final isOwner = role == 'owner';

    final visibleBranches = isOwner ? const [0, 2, 3, 4, 5] : const [0, 1, 3, 4, 5];

    final items = isOwner
        ? const [
            _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
            _NavItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Barangku'),
            _NavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Riwayat'),
            _NavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat'),
            _NavItem(Icons.person_outline, Icons.person, 'Profil'),
          ]
        : const [
            _NavItem(Icons.home_outlined, Icons.home, 'Home'),
            _NavItem(Icons.search_outlined, Icons.search, 'Cari'),
            _NavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Riwayat Sewa'),
            _NavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat'),
            _NavItem(Icons.person_outline, Icons.person, 'Profil'),
          ];

    final selectedVisibleIndex = visibleBranches.indexOf(navigationShell.currentIndex);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedVisibleIndex < 0 ? 0 : selectedVisibleIndex,
        onDestinationSelected: (visibleIndex) {
          final branchIndex = visibleBranches[visibleIndex];
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.activeIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
