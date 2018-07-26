import 'package:flutter/material.dart';


DateTime getCurrentDate() => getDate(DateTime.now());

DateTime getDate(DateTime time) =>
DateTime(time.year, time.month, time.day);


class EventType {
  final String name;
  final Color color;
  final Icon icon;

  EventType(this.name, this.color, icon) : this.icon = Icon(icon, color: color);

  @override
  String toString() {
    return "[$name, $color, $icon]";
  }
}

class Event {
  String name;
  EventType type;
  DateTime start;
  DateTime end;

  Event(this.name, this.type, this.start, this.end);

  @override
  String toString() {
    return "[$name, ${type.name}, $start, $end]";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Event &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              type == other.type &&
              start == other.start &&
              end == other.end;

  @override
  int get hashCode =>
      name.hashCode ^
      type.hashCode ^
      start.hashCode ^
      end.hashCode;

}
