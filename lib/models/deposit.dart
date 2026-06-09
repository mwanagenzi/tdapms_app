import 'badge_info.dart';
import 'deposit_deduction.dart';
import 'escrow_transaction.dart';

class Deposit {
  final int id;
  final int leaseId;
  final double amountRequired;
  final double amountPaid;
  final String status;
  final double outstanding;
  final bool isFullyPaid;
  final double netRefundAmount;
  final String? refundInitiatedAt;
  final String? refundedAt;
  final BadgeInfo? statusBadge;
  final List<EscrowTransaction> escrowTransactions;
  final List<DepositDeduction> deductions;

  const Deposit({
    required this.id,
    required this.leaseId,
    required this.amountRequired,
    required this.amountPaid,
    required this.status,
    required this.outstanding,
    required this.isFullyPaid,
    required this.netRefundAmount,
    this.refundInitiatedAt,
    this.refundedAt,
    this.statusBadge,
    this.escrowTransactions = const [],
    this.deductions = const [],
  });

  factory Deposit.fromJson(Map<String, dynamic> json) => Deposit(
        id: (json['id'] as num?)?.toInt() ?? 0,
        leaseId: (json['lease_id'] as num?)?.toInt() ?? 0,
        amountRequired:
            double.tryParse(json['amount_required']?.toString() ?? '0') ?? 0,
        amountPaid:
            double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0,
        status: json['status'] as String? ?? 'pending',
        outstanding:
            double.tryParse(json['outstanding']?.toString() ?? '0') ?? 0,
        isFullyPaid: json['is_fully_paid'] as bool? ?? false,
        netRefundAmount:
            double.tryParse(json['net_refund_amount']?.toString() ?? '0') ?? 0,
        refundInitiatedAt: json['refund_initiated_at'] as String?,
        refundedAt: json['refunded_at'] as String?,
        statusBadge: json['status_badge'] is Map
            ? BadgeInfo.fromJson(json['status_badge'] as Map<String, dynamic>)
            : null,
        escrowTransactions: (json['escrow_transactions'] as List? ?? [])
            .map((e) =>
                EscrowTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
        deductions: (json['deductions'] as List? ?? [])
            .map((e) =>
                DepositDeduction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
