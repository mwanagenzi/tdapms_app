class BadgeInfo {
  final String label;
  final String color;

  const BadgeInfo({required this.label, required this.color});

  factory BadgeInfo.fromJson(Map<String, dynamic> json) => BadgeInfo(
        label: json['label'] as String? ?? '',
        color: json['color'] as String? ?? 'gray',
      );
}
