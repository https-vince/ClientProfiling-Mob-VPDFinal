class AvailedServiceModel {
  const AvailedServiceModel({
    required this.id,
    required this.eventId,
    required this.notes,
    required this.serviceDate,
    required this.image,
    required this.serialNumberId,
    required this.controlNumber,
    required this.serviceTypeId,
    required this.employeeId,
    required this.clientId,
    required this.shopId,
  });

  final int id;
  final int? eventId;
  final String notes;
  final String serviceDate;
  final String image;
  final String serialNumberId;
  final String controlNumber;
  final String serviceTypeId;
  final int? employeeId;
  final int clientId;
  final int? shopId;

  factory AvailedServiceModel.fromJson(Map<String, dynamic> json) {
    return AvailedServiceModel(
      id: int.tryParse('${json['id'] ?? ''}') ?? 0,
      eventId: int.tryParse('${json['event_id'] ?? ''}'),
      notes: (json['notes'] ?? '').toString(),
      serviceDate: (json['service_date'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      serialNumberId: (json['serial_number_id'] ?? '').toString(),
      controlNumber: (json['control_number'] ?? '').toString(),
      serviceTypeId: (json['service_type_id'] ?? '').toString(),
      employeeId: int.tryParse('${json['employee_id'] ?? ''}'),
      clientId: int.tryParse('${json['client_id'] ?? ''}') ?? 0,
      shopId: int.tryParse('${json['shop_id'] ?? ''}'),
    );
  }
}
