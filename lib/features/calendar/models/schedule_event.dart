import 'package:flutter/material.dart';

enum ScheduleType { pending, tentative, final_, resolved, name }

enum NameType { default_, asterisk }

class ScheduleEvent {
  final String name;
  final ScheduleType type;
  final String contactNo;
  final NameType nameType;
  final String shop;
  final String addressLocation;
  final String pinLocation;
  final String locationLink;
  final String serviceType;
  final String vehicles;
  final String tollAmount;
  final String gasAmount;
  final List<String> technicians;
  final String notes;
  final String createdBy;

  ScheduleEvent({
    required this.name,
    required this.type,
    this.contactNo = '',
    this.nameType = NameType.default_,
    this.shop = '',
    this.addressLocation = '',
    this.pinLocation = '',
    this.locationLink = '',
    this.serviceType = '',
    this.vehicles = '',
    this.tollAmount = '0.00',
    this.gasAmount = '0.00',
    List<String>? technicians,
    this.notes = 'N/A',
    this.createdBy = '',
  }) : technicians = technicians ?? ['N/A', 'N/A', 'N/A', 'N/A', 'N/A'];

  ScheduleEvent copyWith({
    String? name,
    ScheduleType? type,
    String? contactNo,
    NameType? nameType,
    String? shop,
    String? addressLocation,
    String? pinLocation,
    String? locationLink,
    String? serviceType,
    String? vehicles,
    String? tollAmount,
    String? gasAmount,
    List<String>? technicians,
    String? notes,
    String? createdBy,
  }) {
    return ScheduleEvent(
      name: name ?? this.name,
      type: type ?? this.type,
      contactNo: contactNo ?? this.contactNo,
      nameType: nameType ?? this.nameType,
      shop: shop ?? this.shop,
      addressLocation: addressLocation ?? this.addressLocation,
      pinLocation: pinLocation ?? this.pinLocation,
      locationLink: locationLink ?? this.locationLink,
      serviceType: serviceType ?? this.serviceType,
      vehicles: vehicles ?? this.vehicles,
      tollAmount: tollAmount ?? this.tollAmount,
      gasAmount: gasAmount ?? this.gasAmount,
      technicians: technicians ?? List.from(this.technicians),
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  static Color colorForType(ScheduleType type) {
    switch (type) {
      case ScheduleType.pending:
        return const Color(0xFF5B9BD5);
      case ScheduleType.tentative:
        return const Color(0xFFFFA500);
      case ScheduleType.final_:
        return const Color(0xFFE74C3C);
      case ScheduleType.resolved:
        return const Color(0xFF27AE60);
      case ScheduleType.name:
        return const Color(0xFF95A5A6);
    }
  }

  Color get color => colorForType(type);
}
