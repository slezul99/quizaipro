class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalCount,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final int totalCount;

  bool get hasMore => page < totalPages;

  PaginatedResult<T> copyWith({
    List<T>? items,
    int? page,
    int? totalPages,
    int? totalCount,
  }) =>
      PaginatedResult<T>(
        items: items ?? this.items,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
        totalCount: totalCount ?? this.totalCount,
      );
}
