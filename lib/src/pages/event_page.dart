import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../base/base_classes.dart';

void main() => runApp(EventPageRunner());

func(Event event) {
  print("Save $event");
//  Navigator.of(context).pop();
}

class EventPageRunner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Event Page',
        home: EventPage(func, [
          EventType("ev 01", Color.fromRGBO(5, 100, 100, 1.0), Icons.add_alarm),
          EventType(
              "ev 02", Color.fromRGBO(5, 200, 100, 1.0), Icons.card_membership)
        ]));
  }
}

typedef EventPageCallback(Event event);

class EventPage extends StatefulWidget {
  final EventPageCallback onSubmit;
  final List<EventType> eventTypes;

  EventPage(this.onSubmit, this.eventTypes);

  @override
  createState() => _EventPageState(onSubmit, eventTypes);
}

class _EventPageState extends State<EventPage> {
  final List<EventType> eventTypes;
  final EventPageCallback onSubmit;
  final double textScaleFactor = 1.2;
  final dateFormatter = DateFormat('E, dd.MM.yyyy');
  final timeFormatter = DateFormat('HH:mm');
  static final now = DateTime.now();

  String _name = "";
  EventType _eventType;
  DateTime _start = DateTime(now.year, now.month, now.day, now.hour.round());
  DateTime _end = DateTime(now.year, now.month, now.day, now.hour.round() + 1);

  _EventPageState(this.onSubmit, this.eventTypes);

  @override
  Widget build(BuildContext context) {
    if (_eventType == null)
      setState(() {
        _eventType = eventTypes.first;
      });
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: TextField(
                  onChanged: _onNameSaved,
                    decoration: InputDecoration(
                  hintText: "Give title, event name...",
                ))),
            preferredSize: Size(150.0, 32.0)),
        actions: <Widget>[
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Center(child: Text("Save")),
            ),
            onTap: () {
              if (_name != "")
                onSubmit(Event(_name, _eventType, _start, _end));
            },
          )
        ],
      ),
      body: ListView(children: <Widget>[
        _createDatePickerWidgets(),
        _createEventTypeDropdown()
      ]),
    );
  }

  _onNameSaved(String name) {
    setState(() {
      _name = name;
    });
  }


  _onEventTypeSelect(String eventTypeName) {
    setState(() {
      _eventType = eventTypes.where((e) => (e.name == eventTypeName)).first;
    });
  }

  Widget _createEventTypeDropdown() {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
        title: DropdownButton<String>(
        onChanged: (s) => _onEventTypeSelect(s),
        value: _eventType.name,
        items: eventTypes.map((EventType value) {
          return DropdownMenuItem<String>(
            value: value.name,
            child: Text(value.name, textScaleFactor: textScaleFactor,),
          );
        }).toList()));
  }

  _onTimePicker(initialTime, bool startOrEndDate) {
    showTimePicker(
      context: context,
      initialTime: initialTime,
    ).then((time) {
      print(time);
      setState(() {
        if (startOrEndDate) {
          _start = DateTime(
              _start.year, _start.month, _start.day, time.hour, time.minute);
        } else {
          _end = DateTime(_end.year, _end.month, _end.day, time.hour, time.minute);
        }
      });
    });
  }

  _onDatePicker(initialTime, bool startOrEndDate) {
    showDatePicker(
      context: context,
      initialDate: initialTime,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    ).then((date) {
      print(date);
      setState(() {
        if (startOrEndDate) {
          _start = DateTime(
              date.year, date.month, date.day, _start.hour, _start.minute);
        } else {
          _end = DateTime(date.year, date.month, date.day, _end.hour, _end.minute);
        }
      });
    });
  }

  Widget _createDatePickerWidgets() {
    return Container(
        height: 100.0,
        child: ListView(padding: EdgeInsets.all(8.0), children: [
          ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 32.0),
              title: GestureDetector(
                  child: Text(
                    dateFormatter.format(_start),
                    textScaleFactor: textScaleFactor,
                  ),
                  onTap: () => _onDatePicker(_start, true)),
              trailing: GestureDetector(
                  child: Text(timeFormatter.format(_start),
                      textScaleFactor: textScaleFactor)),
              onTap: () => _onTimePicker(
                  TimeOfDay(hour: _start.hour, minute: _start.minute), true)),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 32.0),
            title: GestureDetector(
                child: Text(dateFormatter.format(_end),
                    textScaleFactor: textScaleFactor),
                onTap: () => _onDatePicker(_end, false)),
            trailing: GestureDetector(
                child: Text(timeFormatter.format(_end),
                    textScaleFactor: textScaleFactor),
                onTap: () => _onTimePicker(
                    TimeOfDay(hour: _end.hour, minute: _end.minute), false)),
          )
        ]));
  }
}
