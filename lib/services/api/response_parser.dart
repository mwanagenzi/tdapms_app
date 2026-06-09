/// Normalises a raw Dio response that may be either:
///   • a plain JSON array        → [ {...}, {...} ]
///   • a Laravel Resource wrap   → { "data": [ {...} ] }
///   • a Laravel paginator       → { "data": [...], "current_page": 1, ... }
///
/// Returns the inner list in all cases.
List<dynamic> extractList(dynamic raw) {
  if (raw is List) return raw;
  if (raw is Map) {
    final data = raw['data'];
    if (data is List) return data;
  }
  return [];
}

/// Normalises a response that may be either a paginator Map or a plain List
/// into a Map that always has `data`, `current_page`, `last_page`, `total`.
Map<String, dynamic> normalisePaginated(dynamic raw) {
  if (raw is List) {
    // Backend returned a plain collection — treat as single page.
    return {
      'data': raw,
      'current_page': 1,
      'last_page': 1,
      'total': raw.length,
    };
  }
  if (raw is Map<String, dynamic>) return raw;
  return {'data': [], 'current_page': 1, 'last_page': 1, 'total': 0};
}
