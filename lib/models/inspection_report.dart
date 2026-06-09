import 'inspection_report_item.dart';

class InspectionReport {
  final int id;
  final int leaseId;
  final String type; // move_in | move_out
  final String status; // draft | completed
  final String? notes;
  final String? completedAt;
  final String? conductedByName;
  final List<InspectionReportItem> items;

  const InspectionReport({
    required this.id,
    required this.leaseId,
    required this.type,
    required this.status,
    this.notes,
    this.completedAt,
    this.conductedByName,
    this.items = const [],
  });

  String get typeLabel => type == 'move_in' ? 'Move-In' : 'Move-Out';

  bool get isCompleted => status == 'completed';

  factory InspectionReport.fromJson(Map<String, dynamic> json) =>
      InspectionReport(
        id: (json['id'] as num?)?.toInt() ?? 0,
        leaseId: (json['lease_id'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? 'move_in',
        status: json['status'] as String? ?? 'draft',
        notes: json['notes'] as String?,
        completedAt: json['completed_at'] as String?,
        conductedByName: json['conducted_by'] is Map
            ? (json['conducted_by'] as Map<String, dynamic>)['name'] as String?
            : null,
        items: (json['items'] as List? ?? [])
            .map((e) =>
                InspectionReportItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
