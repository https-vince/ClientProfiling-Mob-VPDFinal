class ShopModel {
  const ShopModel({
    required this.id,
    required this.shopname,
    required this.saddress,
    required this.svibernum,
    required this.semailaddress,
    required this.scontactperson,
    required this.scontactnum,
    required this.notes,
    required this.shopTypeId,
    required this.clientId,
    required this.locationLink,
    required this.pinLocation,
  });

  final int id;
  final String shopname;
  final String saddress;
  final String svibernum;
  final String semailaddress;
  final String scontactperson;
  final String scontactnum;
  final String notes;
  final int? shopTypeId;
  final int clientId;
  final String locationLink;
  final String pinLocation;

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: int.tryParse('${json['id'] ?? ''}') ?? 0,
      shopname: (json['shopname'] ?? '').toString(),
      saddress: (json['saddress'] ?? '').toString(),
      svibernum: (json['svibernum'] ?? '').toString(),
      semailaddress: (json['semailaddress'] ?? '').toString(),
      scontactperson: (json['scontactperson'] ?? '').toString(),
      scontactnum: (json['scontactnum'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      shopTypeId: int.tryParse('${json['shop_type_id'] ?? ''}'),
      clientId: int.tryParse('${json['client_id'] ?? ''}') ?? 0,
      locationLink: (json['location_link'] ?? '').toString(),
      pinLocation: (json['pin_location'] ?? '').toString(),
    );
  }
}
