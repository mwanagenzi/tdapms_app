import 'badge_info.dart';

class EscrowTransaction {
  final int id;
  final int depositId;
  final String type; // collection | refund
  final double amount;
  final String status; // pending | completed | failed | cancelled
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
        id: json['id'] as int,
        depositId: json['deposit_id'] as int,
        type: json['type'] as String,
        amount: double.parse(json['amount'].toString()),
        status: json['status'] as String,
        mpesaReference: json['mpesa_reference'] as String?,
        phone: json['phone'] as String?,
        completedAt: json['completed_at'] as String?,
        statusBadge: json['status_badge'] != null
            ? BadgeInfo.fromJson(json['status_badge'] as Map<String, dynamic>)
            : null,
      );
}
