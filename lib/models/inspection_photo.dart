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
        id: json['id'] as int,
        inspectionReportItemId: json['inspection_report_item_id'] as int,
        path: json['path'] as String,
        caption: json['caption'] as String?,
      );
}
