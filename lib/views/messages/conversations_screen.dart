import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/message_controller.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/conversation.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/error_view.dart';
import '../shared/widgets/loading_spinner.dart';
import '../shared/widgets/offline_banner.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationsControllerProvider);

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
                    : 'Failed to load messages.',
                onRetry: () => ref
                    .read(conversationsControllerProvider.notifier)
                    .refresh(),
              ),
              data: (conversations) => conversations.isEmpty
                  ? const EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No conversations',
                      subtitle:
                          'Conversations linked to your lease and maintenance requests will appear here.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryDark,
                      onRefresh: () => ref
                          .read(conversationsControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        itemCount: conversations.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1),
                        itemBuilder: (_, i) =>
                            _ConversationTile(conv: conversations[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conv;

  const _ConversationTile({required this.conv});

  @override
  Widget build(BuildContext context) {
    final latest = conv.latestMessage;
    final hasUnread = conv.hasUnread;

    return InkWell(
      onTap: () => context.push('/messages/${conv.id}'),
      child: Container(
        color: hasUnread
            ? AppColors.primaryDark.withValues(alpha: 0.03)
            : null,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryDark.withValues(alpha: 0.1),
                  child: Icon(
                    conv.contextLabel == 'Maintenance'
                        ? Icons.build_rounded
                        : Icons.home_rounded,
                    size: 22,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.info,
                        shape: BoxShape.circle,
                        // White ring to separate from avatar
                        // ignore: use_colored_box
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.subject ??
                              '${conv.contextLabel} Thread',
                          style: TextStyle(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (latest != null)
                        Text(
                          timeAgo(latest.createdAt),
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                  if (latest != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${latest.senderName}: ${latest.body}',
                      style: TextStyle(
                        fontSize: 13,
                        color: hasUnread
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                            hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    conv.contextLabel,
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
