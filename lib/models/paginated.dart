class Paginated<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const Paginated({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return Paginated(
      data: (json['data'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }

  Paginated<T> append(Paginated<T> next) {
    return Paginated(
      data: [...data, ...next.data],
      currentPage: next.currentPage,
      lastPage: next.lastPage,
      total: next.total,
    );
  }
}
