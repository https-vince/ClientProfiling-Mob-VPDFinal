class ClientDetailData {
  final Map<String, String> shopDetails;
  final List<Map<String, String>> products;
  final List<Map<String, String>> services;
  final int totalProducts;
  final int currentProductPage;
  final int productsPerPage;

  const ClientDetailData({
    required this.shopDetails,
    required this.products,
    required this.services,
    this.totalProducts = 0,
    this.currentProductPage = 1,
    this.productsPerPage = 5,
  });

  /// Get paginated products for current page
  List<Map<String, String>> getPaginatedProducts() {
    final startIndex = (currentProductPage - 1) * productsPerPage;
    final endIndex = (startIndex + productsPerPage).clamp(0, products.length);
    if (startIndex >= products.length) return [];
    return products.sublist(startIndex, endIndex);
  }

  /// Get total number of pages
  int getTotalProductPages() {
    return (totalProducts / productsPerPage).ceil();
  }

  /// Create a copy with updated pagination
  ClientDetailData copyWith({
    Map<String, String>? shopDetails,
    List<Map<String, String>>? products,
    List<Map<String, String>>? services,
    int? totalProducts,
    int? currentProductPage,
    int? productsPerPage,
  }) {
    return ClientDetailData(
      shopDetails: shopDetails ?? this.shopDetails,
      products: products ?? this.products,
      services: services ?? this.services,
      totalProducts: totalProducts ?? this.totalProducts,
      currentProductPage: currentProductPage ?? this.currentProductPage,
      productsPerPage: productsPerPage ?? this.productsPerPage,
    );
  }
}
