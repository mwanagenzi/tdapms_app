import 'badge_info.dart';
import 'maintenance_update.dart';

class MaintenanceRequest {
  final int id;
  final int unitId;
  final int tenantId;
  final String title;
  final String description;
  final String priority; // low | medium | high | urgent
  final String status; // submitted | in_progress | completed | rejected
  final String createdAt;
  final BadgeInfo? statusBadge;
  final BadgeInfo? priorityBadge;
  final List<MaintenanceUpdate> updates;

  const MaintenanceRequest({
    required this.id,
    required this.unitId,
    required this.tenantId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.statusBadge,
    this.priorityBadge,
    this.updates = const [],
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) =>
      MaintenanceRequest(
        id: json['id'] as int,
        unitId: json['unit_id'] as int,
        tenantId: json['tenant_id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        priority: json['priority'] as String,
        status: json['status'] as String,
        createdAt: json['created_at'] as String,
        statusBadge: json['status_badge'] != null
            ? BadgeInfo.fromJson(json['status_badge'] as Map<String, dynamic>)
            : null,
        priorityBadge: json['priority_badge'] != null
            ? BadgeInfo.fromJson(
                json['priority_badge'] as Map<String, dynamic>)
            : null,
        updates: (json['updates'] as List? ?? [])
            .map((e) =>
                MaintenanceUpdate.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
