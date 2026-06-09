class InspectionPhoto {
  final int id;
  final int inspectionReportItemId;
  final String path;
  final String? caption;

  const InspectionPhoto({
    required this.id,
    required this.inspectionReportItemId,
    required this.path,
    this.caption,
  });

  factory InspectionPhoto.fromJson(Map<String, dynamic> json) =>
      InspectionPhoto(
        id: (json['id'] as num?)?.toInt() ?? 0,
        inspectionReportItemId:
            (json['inspection_report_item_id'] as num?)?.toInt() ?? 0,
        path: json['path'] as String? ?? '',
        caption: json['caption'] as String?,
      );
}
