import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scrolling_calendar/scrolling_calendar.dart';
import './src/base/base_classes.dart';
import './src/pages/event_type_dialog.dart';
import './src/pages/event_page.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrolling calendar',
      initialRoute: '/',
      routes: {'/': (BuildContext context) => MyCalendar()},
    );
  }
}

class MyCalendar extends StatefulWidget {
  @override
  State createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  static final Random random = Random();

  var _scrollingCalendar;
  var _selectedEventType;
  var _sEventTypes = Set<EventType>();
  var _sDateTimeEvents = Map<DateTime, Set<Event>>();

  @override
  initState() {
    print("Init state " + getCurrentDate().toString());
    super.initState();

    _sEventTypes.add(EventType("Default", Colors.grey, Icons.date_range));

    _selectedEventType = _sEventTypes.first;
  }

  Iterable<Color> _getMarkers(DateTime day) {
//    return _saved.contains(day) ? <Color>[Colors.red] : <Color>[];
    day = getDate(day);
    return _sDateTimeEvents.containsKey(day)
        ? (_sDateTimeEvents[day].isNotEmpty
            ? _sDateTimeEvents[day].map((e) => e.type.color).toList()
            : <Color>[])
        : <Color>[];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    _scrollingCalendar = ScrollingCalendar(
      onDateTapped: (DateTime day) => _onDateTapped(day),
      colorMarkers: (DateTime day) => _getMarkers(day),
      selectedDate: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_today), onPressed: _onTodayTapped),
        ],
        title: Text('Mobile Calendar'),
      ),
      drawer: _buildDrawer(themeData),
      body: _scrollingCalendar,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewEvent(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawer(ThemeData themeData) {
    return Opacity(
        opacity: 0.8,
        child: Drawer(
            child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                      // Fake a drawer header
                      Container(
                        color: themeData.primaryColor,
                        padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 8.0),
                        child: Row(children: <Widget>[
                          Expanded(
                              flex: 4,
                              child: ListTile(
                                title:
                                    Text("Event types", textScaleFactor: 1.5),
                              )),
                          Expanded(
                              flex: 1,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FlatButton(
                                      onPressed: _createNewEventTypeDialog,
                                      child: Icon(Icons.library_add))))
                        ]),
                      )
                    ] +
                    _sEventTypes.map((d) => _buildDrawerRow(d)).toList())));
  }

  Widget _buildDrawerRow(EventType e) {
    return Container(
        color: e == _selectedEventType ? Colors.blueGrey : null,
        child: ListTile(
          trailing: e.icon,
          title: Text(e.name),
          onTap: () {
            setState(() {
              _selectedEventType = e;
            });
            Navigator.of(context).pop();
          },
        ));
  }

  _onDateTapped(DateTime day) {
    day = getDate(day);
    var event = Event("{$_selectedEventType.name} $day", _selectedEventType,
        day, day.add(Duration(minutes: 30)));

    print("Add $event");

    _saveEvent(event, day);
  }

  _saveEvent(Event event, DateTime day) {
    final alreadySaved = _sDateTimeEvents.containsKey(day) &&
        _sDateTimeEvents[day].contains(event);

    setState(() {
      if (!alreadySaved) {
        _sDateTimeEvents.putIfAbsent(day, () => Set<Event>());
        _sDateTimeEvents[day].add(event);
      } else if (_sDateTimeEvents.containsKey(day)) {
        _sDateTimeEvents[day].remove(event);
      }
    });
  }

  _createNewEvent() {
    print("Create event");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return EventPage(_onSubmitEvent, _sEventTypes.toList());
        },
      ),
    );
  }

  _onSubmitEvent(Event event) {
    print("Save new Event: $event");
    var day = getDate(event.start);
    _saveEvent(event, day);
    Navigator.of(context).pop();
  }

  _onTodayTapped() {
    print("Today button tapped");
    _scrollingCalendar.jumpToMonth(DateTime.now());
  }

  _onSubmitEventTypeDialog(EventType eventType) {
    print("Submit new Event type: $eventType");
    setState(() {
      _sEventTypes.add(eventType);
      _selectedEventType = eventType;
    });
    Navigator.of(context).pop();
  }

  _createNewEventTypeDialog() {
    print("Create new event dialog");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return EventTypeDialog(onSubmit: _onSubmitEventTypeDialog);
        });
  }
}
