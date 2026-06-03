class MaintenanceUpdate {
  final int id;
  final int maintenanceRequestId;
  final String status;
  final String notes;
  final String? updatedByName;
  final String createdAt;

  const MaintenanceUpdate({
    required this.id,
    required this.maintenanceRequestId,
    required this.status,
    required this.notes,
    this.updatedByName,
    required this.createdAt,
  });

  factory MaintenanceUpdate.fromJson(Map<String, dynamic> json) =>
      MaintenanceUpdate(
        id: json['id'] as int,
        maintenanceRequestId: json['maintenance_request_id'] as int,
        status: json['status'] as String,
        notes: json['notes'] as String,
        updatedByName:
            (json['updated_by'] as Map<String, dynamic>?)?['name'] as String?,
        createdAt: json['created_at'] as String,
      );
}
