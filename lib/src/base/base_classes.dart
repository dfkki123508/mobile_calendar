import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

DateTime getCurrentDate() => getDate(DateTime.now());

DateTime getDate(DateTime time) => DateTime(time.year, time.month, time.day);

class EventType {
  String uuid;
  String name;
  Color color;
  Icon icon;

  EventType(this.name, this.color, icon, {uuid}) {
    this.icon = Icon(icon, color: color);
    this.uuid = uuid ?? Uuid().v5(Uuid.NAMESPACE_URL, name);
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'color': {
        'r': color.red,
        'g': color.green,
        'b': color.blue,
        'o': color.opacity
      },
      'icon': icon.icon.codePoint,
      'classtype': this.runtimeType.toString()
    };
  }

  static EventType fromMap(Map map) {
    Color color = Color.fromRGBO(map['color']['r'], map['color']['g'],
        map['color']['b'], map['color']['o']);
    return EventType(map['name'], color, IconData(map['icon']),
        uuid: map['uuid']);
  }

  @override
  String toString() {
    return "[$name, $color, $icon]";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventType &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color &&
          icon == other.icon;

  @override
  int get hashCode => name.hashCode ^ color.hashCode ^ icon.hashCode;
}

class Event {
  // uuid
  String uuid;
  String name;
  EventType type;
  DateTime start;
  DateTime end;

  Event(this.name, this.type, this.start, this.end, {uuid}) {
    this.uuid = uuid ?? Uuid().v5(Uuid.NAMESPACE_URL, name);
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'type': type.name,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'classtype': this.runtimeType.toString()
    };
  }

  static Event fromMap(Map map, eventTypes) {
    return Event(
        map['name'],
        eventTypes.where((e) => (e.name == map['type'])).first,
        DateTime.parse(map['start']),
        DateTime.parse(map['end']),
        uuid: map['uuid']);
  }

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
      uuid.hashCode ^
      name.hashCode ^
      type.hashCode ^
      start.hashCode ^
      end.hashCode;
}
