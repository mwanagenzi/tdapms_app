import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/notification_controller.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/tenant_notification.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/error_view.dart';
import '../shared/widgets/loading_spinner.dart';
import '../shared/widgets/offline_banner.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: state.when(
              loading: () => const LoadingSpinner(),
              error: (err, _) => ErrorView(
                message: err is AppException
                    ? err.message
                    : 'Failed to load notifications.',
                onRetry: () =>
                    ref.read(notificationControllerProvider.notifier).refresh(),
              ),
              data: (page) => page.items.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications',
                      subtitle: 'You\'re all caught up.',
                    )
                  : Column(
                      children: [
                        if (page.unreadCount > 0)
                          _MarkAllReadBar(
                            count: page.unreadCount,
                            onMarkAll: () => ref
                                .read(notificationControllerProvider.notifier)
                                .markAllRead(),
                          ),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.primaryDark,
                            onRefresh: () => ref
                                .read(notificationControllerProvider.notifier)
                                .refresh(),
                            child: ListView.separated(
                              itemCount: page.items.length +
                                  (page.hasMore ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                if (i == page.items.length) {
                                  return TextButton(
                                    onPressed: () => ref
                                        .read(notificationControllerProvider
                                            .notifier)
                                        .loadMore(),
                                    child: const Text('Load more'),
                                  );
                                }
                                return _NotificationTile(
                                  notification: page.items[i],
                                  onTap: () => ref
                                      .read(notificationControllerProvider
                                          .notifier)
                                      .markRead(page.items[i].id),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkAllReadBar extends StatelessWidget {
  final int count;
  final VoidCallback onMarkAll;

  const _MarkAllReadBar({required this.count, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.info.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            '$count unread',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onMarkAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.info,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Mark all read',
                style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final TenantNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  IconData _iconForType(String type) {
    if (type.contains('deposit')) return Icons.account_balance_wallet_rounded;
    if (type.contains('deduction')) return Icons.remove_circle_outline_rounded;
    if (type.contains('maintenance')) return Icons.build_rounded;
    if (type.contains('message')) return Icons.chat_bubble_rounded;
    return Icons.notifications_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;

    return InkWell(
      onTap: isUnread ? onTap : null,
      child: Container(
        color: isUnread
            ? AppColors.primaryDark.withValues(alpha: 0.03)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForType(notification.type),
                    size: 20,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.info,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: isUnread
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(notification.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.disabled),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
