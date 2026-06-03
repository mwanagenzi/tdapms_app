import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/deposit_controller.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/deposit.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/error_view.dart';
import '../shared/widgets/loading_spinner.dart';
import '../shared/widgets/offline_banner.dart';
import '../shared/widgets/status_badge.dart';

class DepositsScreen extends ConsumerWidget {
  const DepositsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(depositsControllerProvider);

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
                    : 'Failed to load deposits.',
                onRetry: () =>
                    ref.read(depositsControllerProvider.notifier).refresh(),
              ),
              data: (deposits) => deposits.isEmpty
                  ? const EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No deposits found',
                      subtitle:
                          'Your deposit history will appear here once recorded.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryDark,
                      onRefresh: () => ref
                          .read(depositsControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: deposits.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _DepositCard(deposit: deposits[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositCard extends StatelessWidget {
  final Deposit deposit;

  const _DepositCard({required this.deposit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/deposits/${deposit.id}'),
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
                    'Deposit #${deposit.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (deposit.statusBadge != null)
                  StatusBadge.fromBadgeInfo(deposit.statusBadge!),
              ],
            ),
            const SizedBox(height: 12),
            _AmountRow(
              label: 'Required',
              value: formatCurrency(deposit.amountRequired),
            ),
            _AmountRow(
              label: 'Paid',
              value: formatCurrency(deposit.amountPaid),
              valueColor: AppColors.success,
            ),
            if (deposit.outstanding > 0)
              _AmountRow(
                label: 'Outstanding',
                value: formatCurrency(deposit.outstanding),
                valueColor: AppColors.danger,
              ),
            if (deposit.status == 'refunding' ||
                deposit.status == 'refunded') ...[
              const Divider(height: 20),
              _AmountRow(
                label: 'Net refund',
                value: formatCurrency(deposit.netRefundAmount),
                valueColor: AppColors.info,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                Text(
                  'View details',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _AmountRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
