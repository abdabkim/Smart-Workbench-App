// automation_schedule.dart

import 'package:flutter/material.dart';

enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class AutomationSchedule {
  final String name;
  final String device;
  final Set<DayOfWeek> days;
  final TimeOfDay timeOfDay;
  final bool action; // true for turn on, false for turn off

  AutomationSchedule({
    required this.name,
    required this.device,
    required this.days,
    required this.timeOfDay,
    required this.action,
  });

  AutomationSchedule copyWith({
    String? name,
    String? device,
    Set<DayOfWeek>? days,
    TimeOfDay? timeOfDay,
    bool? action,
  }) {
    return AutomationSchedule(
      name: name ?? this.name,
      device: device ?? this.device,
      days: days ?? this.days,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      action: action ?? this.action,
    );
  }

  String getFormattedDays() {
    if (days.length == 7) return 'Every day';
    if (days.length == 5 &&
        days.contains(DayOfWeek.monday) &&
        days.contains(DayOfWeek.friday)) return 'Weekdays';
    return days
        .map((day) => day.toString().split('.').last.capitalize())
        .join(', ');
  }

  String getFormattedTime() {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'device': device,
      'days': days.map((d) => d.index).toList(),
      'hour': timeOfDay.hour,
      'minute': timeOfDay.minute,
      'action': action,
    };
  }

  static AutomationSchedule fromJson(Map<String, dynamic> json) {
    return AutomationSchedule(
      name: json['name'],
      device: json['device'],
      days: (json['days'] as List)
          .map((i) => DayOfWeek.values[i as int])
          .toSet(),
      timeOfDay: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      action: json['action'] as bool,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}