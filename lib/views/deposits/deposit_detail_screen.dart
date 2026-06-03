import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/deposit_controller.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/deposit.dart';
import '../../models/deposit_deduction.dart';
import '../../models/escrow_transaction.dart';
import '../shared/widgets/error_view.dart';
import '../shared/widgets/loading_spinner.dart';
import '../shared/widgets/section_card.dart';
import '../shared/widgets/status_badge.dart';

class DepositDetailScreen extends ConsumerWidget {
  final int id;

  const DepositDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(depositDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Details'),
        leading: const BackButton(),
      ),
      body: state.when(
        loading: () => const LoadingSpinner(),
        error: (err, _) => ErrorView(
          message:
              err is AppException ? err.message : 'Failed to load deposit.',
          onRetry: () =>
              ref.read(depositDetailProvider(id).notifier).refresh(),
        ),
        data: (deposit) => RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: () =>
              ref.read(depositDetailProvider(id).notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummarySection(deposit: deposit),
              const SizedBox(height: 16),
              _EscrowTimeline(transactions: deposit.escrowTransactions),
              if (deposit.deductions.isNotEmpty) ...[
                const SizedBox(height: 16),
                _DeductionsSection(
                  deductions: deposit.deductions,
                  netRefund: deposit.netRefundAmount,
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/inspections'),
                icon: const Icon(Icons.search_rounded),
                label: const Text('View Inspection Reports'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final Deposit deposit;

  const _SummarySection({required this.deposit});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'SUMMARY',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const SizedBox(
                  width: 140,
                  child: Text('Status',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
                if (deposit.statusBadge != null)
                  StatusBadge.fromBadgeInfo(deposit.statusBadge!),
              ],
            ),
          ),
          InfoRow(
            label: 'Amount required',
            value: formatCurrency(deposit.amountRequired),
          ),
          InfoRow(
            label: 'Amount paid',
            value: formatCurrency(deposit.amountPaid),
            valueColor: AppColors.success,
          ),
          if (deposit.outstanding > 0)
            InfoRow(
              label: 'Outstanding',
              value: formatCurrency(deposit.outstanding),
              valueColor: AppColors.danger,
            ),
          if (deposit.isFullyPaid)
            InfoRow(
              label: 'Net refund',
              value: formatCurrency(deposit.netRefundAmount),
              valueColor: AppColors.info,
            ),
          if (deposit.refundInitiatedAt != null)
            InfoRow(
              label: 'Refund initiated',
              value: formatDateTime(deposit.refundInitiatedAt),
            ),
          if (deposit.refundedAt != null)
            InfoRow(
              label: 'Refunded on',
              value: formatDateTime(deposit.refundedAt),
              valueColor: AppColors.success,
            ),
        ],
      ),
    );
  }
}

class _EscrowTimeline extends StatelessWidget {
  final List<EscrowTransaction> transactions;

  const _EscrowTimeline({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'MPESA TRANSACTIONS',
      padding: EdgeInsets.zero,
      child: transactions.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No transactions yet.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          : Column(
              children: transactions
                  .asMap()
                  .entries
                  .map((entry) => _TransactionTile(
                        tx: entry.value,
                        showDivider: entry.key < transactions.length - 1,
                      ))
                  .toList(),
            ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final EscrowTransaction tx;
  final bool showDivider;

  const _TransactionTile({required this.tx, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final isCollection = tx.type == 'collection';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCollection
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.info.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCollection
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 18,
                  color: isCollection ? AppColors.success : AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCollection ? 'Deposit payment' : 'Refund',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (tx.mpesaReference != null)
                      Text(
                        'Ref: ${tx.mpesaReference}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    if (tx.completedAt != null)
                      Text(
                        formatDateTime(tx.completedAt),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(tx.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color:
                          isCollection ? AppColors.success : AppColors.info,
                    ),
                  ),
                  if (tx.statusBadge != null)
                    StatusBadge.fromBadgeInfo(tx.statusBadge!),
                ],
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 64),
      ],
    );
  }
}

class _DeductionsSection extends StatelessWidget {
  final List<DepositDeduction> deductions;
  final double netRefund;

  const _DeductionsSection({
    required this.deductions,
    required this.netRefund,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'DEPOSIT DEDUCTIONS',
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ...deductions.asMap().entries.map((e) => Column(
                children: [
                  _DeductionTile(deduction: e.value),
                  if (e.key < deductions.length - 1)
                    const Divider(height: 1),
                ],
              )),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Net refund amount',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  formatCurrency(netRefund),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeductionTile extends StatelessWidget {
  final DepositDeduction deduction;

  const _DeductionTile({required this.deduction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deduction.reason,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                formatCurrency(deduction.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (deduction.statusBadge != null)
                StatusBadge.fromBadgeInfo(deduction.statusBadge!),
              if (deduction.description != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    deduction.description!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (deduction.reviewNotes != null) ...[
            const SizedBox(height: 4),
            Text(
              'Note: ${deduction.reviewNotes}',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
