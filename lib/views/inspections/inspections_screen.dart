import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/inspection_controller.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/inspection_report.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/error_view.dart';
import '../shared/widgets/loading_spinner.dart';
import '../shared/widgets/offline_banner.dart';

class InspectionsScreen extends ConsumerWidget {
  const InspectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection History'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: state.when(
              loading: () => const LoadingSpinner(),
              error: (err, _) => ErrorView(
                message: err is AppException ? err.message : err.toString(),
                onRetry: () =>
                    ref.read(inspectionsControllerProvider.notifier).refresh(),
              ),
              data: (reports) => reports.isEmpty
                  ? const EmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No inspection reports',
                      subtitle:
                          'Your move-in and move-out reports will appear here.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryDark,
                      onRefresh: () => ref
                          .read(inspectionsControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: reports.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _InspectionCard(report: reports[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  final InspectionReport report;

  const _InspectionCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final isMoveIn = report.type == 'move_in';

    return InkWell(
      onTap: () => context.push('/inspections/${report.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isMoveIn
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isMoveIn
                    ? Icons.login_rounded
                    : Icons.logout_rounded,
                color: isMoveIn ? AppColors.success : AppColors.warning,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.typeLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    report.isCompleted
                        ? 'Completed ${formatDate(report.completedAt)}'
                        : 'Draft',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (report.conductedByName != null)
                    Text(
                      'By ${report.conductedByName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
