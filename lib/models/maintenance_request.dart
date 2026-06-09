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
    this.updates = const [],
  });

  // ---------------------------------------------------------------------------
  // Derive badges locally — never depend on backend computed attributes.
  // ---------------------------------------------------------------------------

  BadgeInfo get statusBadge {
    switch (status) {
      case 'submitted':
        return const BadgeInfo(label: 'Submitted', color: 'blue');
      case 'in_progress':
        return const BadgeInfo(label: 'In Progress', color: 'yellow');
      case 'completed':
        return const BadgeInfo(label: 'Completed', color: 'green');
      case 'rejected':
        return const BadgeInfo(label: 'Rejected', color: 'red');
      default:
        return BadgeInfo(
          label: status.replaceAll('_', ' '),
          color: 'gray',
        );
    }
  }

  BadgeInfo get priorityBadge {
    switch (priority) {
      case 'low':
        return const BadgeInfo(label: 'Low', color: 'green');
      case 'medium':
        return const BadgeInfo(label: 'Medium', color: 'yellow');
      case 'high':
        return const BadgeInfo(label: 'High', color: 'orange');
      case 'urgent':
        return const BadgeInfo(label: 'Urgent', color: 'red');
      default:
        return BadgeInfo(label: priority, color: 'gray');
    }
  }

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) =>
      MaintenanceRequest(
        // Use safe numeric parsing — backend may return int or num.
        id: (json['id'] as num?)?.toInt() ?? 0,
        unitId: (json['unit_id'] as num?)?.toInt() ?? 0,
        tenantId: (json['tenant_id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        priority: json['priority'] as String? ?? 'medium',
        status: json['status'] as String? ?? 'submitted',
        createdAt: json['created_at'] as String? ?? '',
        updates: (json['updates'] as List? ?? [])
            .map((e) =>
                MaintenanceUpdate.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
