import 'badge_info.dart';
import 'inspection_photo.dart';

class InspectionReportItem {
  final int id;
  final int inspectionReportId;
  final String category;
  final String itemName;
  final String condition; // good | fair | damaged | missing
  final String? notes;
  final BadgeInfo? conditionBadge;
  final List<InspectionPhoto> photos;

  const InspectionReportItem({
    required this.id,
    required this.inspectionReportId,
    required this.category,
    required this.itemName,
    required this.condition,
    this.notes,
    this.conditionBadge,
    this.photos = const [],
  });

  factory InspectionReportItem.fromJson(Map<String, dynamic> json) =>
      InspectionReportItem(
        id: json['id'] as int,
        inspectionReportId: json['inspection_report_id'] as int,
        category: json['category'] as String,
        itemName: json['item_name'] as String,
        condition: json['condition'] as String,
        notes: json['notes'] as String?,
        conditionBadge: json['condition_badge'] != null
            ? BadgeInfo.fromJson(
                json['condition_badge'] as Map<String, dynamic>)
            : null,
        photos: (json['photos'] as List? ?? [])
            .map((e) => InspectionPhoto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
