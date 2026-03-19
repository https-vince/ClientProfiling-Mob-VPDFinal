class PaginatedResponse<T> {
  final int currentPage;
  final int lastPage;
  final int total;
  final String? nextPageUrl;
  final List<T> data;

  const PaginatedResponse({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.nextPageUrl,
    required this.data,
  });

  bool get hasNextPage => nextPageUrl != null && nextPageUrl!.isNotEmpty;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) mapper,
  ) {
    final rawData = json['data'];
    final list = rawData is List
        ? rawData.whereType<Map<String, dynamic>>().map(mapper).toList()
        : <T>[];

    return PaginatedResponse<T>(
      currentPage: int.tryParse((json['current_page'] ?? 1).toString()) ?? 1,
      lastPage: int.tryParse((json['last_page'] ?? 1).toString()) ?? 1,
      total: int.tryParse((json['total'] ?? list.length).toString()) ?? list.length,
      nextPageUrl: json['next_page_url']?.toString(),
      data: list,
    );
  }
}
