import 'badge_info.dart';

class EscrowTransaction {
  final int id;
  final int depositId;
  final String type;
  final double amount;
  final String status;
  final String? mpesaReference;
  final String? phone;
  final String? completedAt;
  final BadgeInfo? statusBadge;

  const EscrowTransaction({
    required this.id,
    required this.depositId,
    required this.type,
    required this.amount,
    required this.status,
    this.mpesaReference,
    this.phone,
    this.completedAt,
    this.statusBadge,
  });

  factory EscrowTransaction.fromJson(Map<String, dynamic> json) =>
      EscrowTransaction(
        id: (json['id'] as num?)?.toInt() ?? 0,
        depositId: (json['deposit_id'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? 'collection',
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
        status: json['status'] as String? ?? 'pending',
        mpesaReference: json['mpesa_reference'] as String?,
        phone: json['phone'] as String?,
        completedAt: json['completed_at'] as String?,
        statusBadge: json['status_badge'] is Map
            ? BadgeInfo.fromJson(json['status_badge'] as Map<String, dynamic>)
            : null,
      );
}
