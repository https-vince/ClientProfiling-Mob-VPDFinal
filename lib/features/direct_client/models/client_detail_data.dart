class ClientDetailData {
  const ClientDetailData({
    required this.shopDetails,
    required this.products,
    required this.services,
    required this.totalProducts,
    required this.currentProductPage,
    required this.productsPerPage,
  });

  final Map<String, String> shopDetails;
  final List<Map<String, String>> products;
  final List<Map<String, String>> services;
  final int totalProducts;
  final int currentProductPage;
  final int productsPerPage;
}
