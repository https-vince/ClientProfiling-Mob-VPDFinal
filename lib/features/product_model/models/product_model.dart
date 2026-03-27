class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;

  // Fields shown in the image form screens
  final String modelCode;
  final String washerCode;
  final String dryerCode;
  final String stylerCode;
  final String paymentSystem;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    this.modelCode = '',
    this.washerCode = '',
    this.dryerCode = '',
    this.stylerCode = '',
    this.paymentSystem = '',
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    String? description,
    String? modelCode,
    String? washerCode,
    String? dryerCode,
    String? stylerCode,
    String? paymentSystem,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      description: description ?? this.description,
      modelCode: modelCode ?? this.modelCode,
      washerCode: washerCode ?? this.washerCode,
      dryerCode: dryerCode ?? this.dryerCode,
      stylerCode: stylerCode ?? this.stylerCode,
      paymentSystem: paymentSystem ?? this.paymentSystem,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      modelCode: json['modelCode'] ?? '',
      washerCode: json['washerCode'] ?? '',
      dryerCode: json['dryerCode'] ?? '',
      stylerCode: json['stylerCode'] ?? '',
      paymentSystem: json['paymentSystem'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'description': description,
      'modelCode': modelCode,
      'washerCode': washerCode,
      'dryerCode': dryerCode,
      'stylerCode': stylerCode,
      'paymentSystem': paymentSystem,
    };
  }
}
