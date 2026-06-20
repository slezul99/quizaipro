class PaginatedDto<T> {
  const PaginatedDto({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalCount,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final int totalCount;

  static PaginatedDto<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItemJson,
  ) {
    return PaginatedDto<T>(
      items: (json['items'] as List<dynamic>)
          .map((e) => fromItemJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      totalPages: (json['total_pages'] as int?) ?? 1,
      totalCount: (json['total_count'] as int?) ?? 0,
    );
  }
}
