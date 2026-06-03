import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/deposit_controller.dart';
import '../../controllers/inspection_controller.dart';
import '../../controllers/maintenance_controller.dart';
import '../../controllers/message_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../core/theme/app_theme.dart';

class HomeShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;

  const HomeShell({super.key, required this.shell});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAll();
    }
  }

  void _refreshAll() {
    ref.read(depositsControllerProvider.notifier).refresh();
    ref.read(maintenanceControllerProvider.notifier).refresh();
    ref.read(conversationsControllerProvider.notifier).refresh();
    ref.read(notificationControllerProvider.notifier).refresh();
    ref.read(inspectionsControllerProvider.notifier).refresh();
  }

  void _onTabTap(int index) {
    if (widget.shell.currentIndex == index) {
      // Tapping the active tab refreshes its data.
      switch (index) {
        case 0:
          ref.read(depositsControllerProvider.notifier).refresh();
        case 1:
          ref.read(maintenanceControllerProvider.notifier).refresh();
        case 2:
          ref.read(conversationsControllerProvider.notifier).refresh();
        case 3:
          ref.read(notificationControllerProvider.notifier).refresh();
      }
    } else {
      widget.shell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);
    final user = ref.watch(authControllerProvider).valueOrNull?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TDAPS',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.white.withValues(alpha: 0.15),
                child: Text(
                  user?.initials ?? '?',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'logout', child: Text('Sign out')),
              ],
              onSelected: (v) {
                if (v == 'logout') {
                  ref.read(authControllerProvider.notifier).logout();
                }
              },
            ),
          ),
        ],
      ),
      body: widget.shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.shell.currentIndex,
        onTap: _onTabTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Deposits',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build_rounded),
            label: 'Maintenance',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_rounded),
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
