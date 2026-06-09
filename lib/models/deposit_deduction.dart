import 'badge_info.dart';

class DepositDeduction {
  final int id;
  final int leaseId;
  final int? inspectionReportItemId;
  final String reason;
  final String? description;
  final double amount;
  final String status;
  final String? reviewedAt;
  final String? reviewNotes;
  final BadgeInfo? statusBadge;

  const DepositDeduction({
    required this.id,
    required this.leaseId,
    this.inspectionReportItemId,
    required this.reason,
    this.description,
    required this.amount,
    required this.status,
    this.reviewedAt,
    this.reviewNotes,
    this.statusBadge,
  });

  factory DepositDeduction.fromJson(Map<String, dynamic> json) =>
      DepositDeduction(
        id: (json['id'] as num?)?.toInt() ?? 0,
        leaseId: (json['lease_id'] as num?)?.toInt() ?? 0,
        inspectionReportItemId:
            (json['inspection_report_item_id'] as num?)?.toInt(),
        reason: json['reason'] as String? ?? '',
        description: json['description'] as String?,
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
        status: json['status'] as String? ?? 'pending',
        reviewedAt: json['reviewed_at'] as String?,
        reviewNotes: json['review_notes'] as String?,
        statusBadge: json['status_badge'] is Map
            ? BadgeInfo.fromJson(json['status_badge'] as Map<String, dynamic>)
            : null,
      );
}
