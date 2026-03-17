class DirectClientData {
  final int overallOwner;
  final int overallCoOwner;
  final int overallShops;
  final int soldProducts;
  final int successfulService;
  final List<Map<String, String>> clients;

  const DirectClientData({
    required this.overallOwner,
    required this.overallCoOwner,
    required this.overallShops,
    required this.soldProducts,
    required this.successfulService,
    required this.clients,
  });
}
