import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/maintenance_controller.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/maintenance_request.dart';
import '../../models/maintenance_update.dart';
import '../shared/widgets/error_view.dart';
import '../shared/widgets/loading_spinner.dart';
import '../shared/widgets/section_card.dart';
import '../shared/widgets/status_badge.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  final int id;

  const MaintenanceDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenanceDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        leading: const BackButton(),
      ),
      body: state.when(
        loading: () => const LoadingSpinner(),
        error: (err, _) => ErrorView(
          message: err is AppException ? err.message : err.toString(),
          onRetry: () =>
              ref.read(maintenanceDetailProvider(id).notifier).refresh(),
        ),
        data: (request) => RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: () =>
              ref.read(maintenanceDetailProvider(id).notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RequestInfoSection(request: request),
              const SizedBox(height: 16),
              _UpdateTimeline(updates: request.updates),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestInfoSection extends StatelessWidget {
  final MaintenanceRequest request;

  const _RequestInfoSection({required this.request});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'REQUEST DETAILS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusBadge.fromBadgeInfo(request.statusBadge),
              const SizedBox(width: 8),
              StatusBadge.fromBadgeInfo(request.priorityBadge),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Submitted ${formatDateTime(request.createdAt)}',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _UpdateTimeline extends StatelessWidget {
  final List<MaintenanceUpdate> updates;

  const _UpdateTimeline({required this.updates});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'STATUS HISTORY',
      padding: EdgeInsets.zero,
      child: updates.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No updates yet. Your request has been received.',
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: updates
                  .asMap()
                  .entries
                  .map(
                    (e) => Column(
                      children: [
                        _UpdateTile(update: e.value),
                        if (e.key < updates.length - 1)
                          const Divider(height: 1, indent: 56),
                      ],
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _UpdateTile extends StatelessWidget {
  final MaintenanceUpdate update;

  const _UpdateTile({required this.update});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.update_rounded,
                size: 16, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      update.status
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeAgo(update.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  update.notes,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                if (update.updatedByName != null)
                  Text(
                    '— ${update.updatedByName}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.disabled),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
