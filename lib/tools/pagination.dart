/// Pagination helper for backend API calls
class Pagination {
  static const int defaultPageSize = 25;

  int currentPage = 1;
  int pageSize;
  int totalItems = 0;

  Pagination({this.pageSize = defaultPageSize});

  int get offset => (currentPage - 1) * pageSize;

  int get totalPages => (totalItems / pageSize).ceil();

  bool get hasNextPage => currentPage < totalPages;

  bool get hasPreviousPage => currentPage > 1;

  void nextPage() {
    if (hasNextPage) currentPage++;
  }

  void previousPage() {
    if (hasPreviousPage) currentPage--;
  }

  void reset() {
    currentPage = 1;
  }

  /// Build query parameters for API calls
  Map<String, String> toQueryParams() {
    return {'limit': pageSize.toString(), 'offset': offset.toString()};
  }
}
