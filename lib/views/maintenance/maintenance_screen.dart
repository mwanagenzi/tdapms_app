import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/maintenance_controller.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/maintenance_request.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/error_view.dart';
import '../shared/widgets/loading_spinner.dart';
import '../shared/widgets/offline_banner.dart';
import '../shared/widgets/status_badge.dart';

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenanceControllerProvider);

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
                    : err.toString(),
                onRetry: () =>
                    ref.read(maintenanceControllerProvider.notifier).refresh(),
              ),
              data: (page) => page.items.isEmpty
                  ? EmptyState(
                      icon: Icons.build_outlined,
                      title: 'No maintenance requests',
                      subtitle: 'Tap + to submit a new request.',
                      action: FilledButton.icon(
                        onPressed: () => context.push('/maintenance/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Submit Request'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryDark,
                      onRefresh: () => ref
                          .read(maintenanceControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            page.items.length + (page.hasMore ? 1 : 0),
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          if (i == page.items.length) {
                            return _LoadMoreButton(
                              isLoading: page.isLoadingMore,
                              onTap: () => ref
                                  .read(maintenanceControllerProvider.notifier)
                                  .loadMore(),
                            );
                          }
                          return _RequestCard(request: page.items[i]);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/maintenance/new'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final MaintenanceRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/maintenance/${request.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge.fromBadgeInfo(request.statusBadge),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              request.description,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                StatusBadge.fromBadgeInfo(request.priorityBadge),
                const Spacer(),
                Text(
                  timeAgo(request.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LoadMoreButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingSpinner(size: 24),
            )
          : TextButton(
              onPressed: onTap,
              child: const Text('Load more'),
            ),
    );
  }
}
