class ProductModel {
  const ProductModel({
    required this.id,
    required this.modelName,
    required this.unitsofmeasurement,
    required this.contractDate,
    required this.deliveryDate,
    required this.installmentDate,
    required this.notes,
    required this.clientId,
    required this.modelCode,
    required this.applianceType,
    required this.employeeId,
  });

  final int id;
  final String modelName;
  final String unitsofmeasurement;
  final String contractDate;
  final String deliveryDate;
  final String installmentDate;
  final String notes;
  final int clientId;
  final String modelCode;
  final String applianceType;
  final int employeeId;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse('${json['id'] ?? ''}') ?? 0,
      modelName: (json['model_name'] ?? '').toString(),
      unitsofmeasurement: (json['unitsofmeasurement'] ?? '').toString(),
      contractDate: (json['contract_date'] ?? '').toString(),
      deliveryDate: (json['delivery_date'] ?? '').toString(),
      installmentDate: (json['installment_date'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      clientId: int.tryParse('${json['client_id'] ?? ''}') ?? 0,
      modelCode: (json['model_code'] ?? '').toString(),
      applianceType: (json['appliance_type'] ?? '').toString(),
      employeeId: int.tryParse('${json['employee_id'] ?? ''}') ?? 0,
    );
  }
}
