import 'package:flutter/material.dart';

enum ScheduleType { pending, tentative, final_, resolved, name }

class ScheduleEvent {
  final String name;
  final ScheduleType type;

  ScheduleEvent({required this.name, required this.type});

  ScheduleEvent copyWith({String? name, ScheduleType? type}) {
    return ScheduleEvent(
      name: name ?? this.name,
      type: type ?? this.type,
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
