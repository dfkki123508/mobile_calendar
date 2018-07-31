import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrolling_calendar/scrolling_calendar.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';

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

  EventType _selectedEventType;
  ObjectDB _db;
  var _scrollingCalendar;
  var _sEventTypes = Set<EventType>();
  var _sDateTimeEvents = Map<DateTime, Set<Event>>();

  @override
  initState() {
    print("Init state " + getCurrentDate().toString());
    super.initState();

    // load db state
    _loadStateFromDB().then((f) {
      _selectedEventType =
          _sEventTypes.where((e) => (e.name == "Default")).first;
      setState((){});
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    if (!(await Directory(directory.path).exists())) {
      Directory(directory.path).createSync(recursive: true);
    }
    return directory.path + "/mobile_calender.db";
    ;
  }

  Future _loadStateFromDB() async {
    print("Loading state from DB...");

    var dbPath = await _localPath;
    print(dbPath);

    if (_db == null) _db = ObjectDB(dbPath);
    _db.open();

    _sEventTypes = (await _db.find({'classtype': 'EventType'}))
        .map((l) => (EventType.fromMap(l)))
        .toSet();

    if (_sEventTypes.isEmpty) {
      _sEventTypes.add(
          EventType("Default", Colors.grey.withOpacity(1.0), Icons.date_range));
      await _saveEventTypesToDB();
    }

    var storedEvents = (await _db.find({'classtype': 'Event'}))
        .map((l) => (Event.fromMap(l, _sEventTypes)));

    for (var e in storedEvents) {
      var day = getDate(e.start);
      _sDateTimeEvents.putIfAbsent(day, () => Set<Event>());
      _sDateTimeEvents[day].add(e);
    }

    print("Loaded event types: $_sEventTypes");
    print("Loaded events: $_sDateTimeEvents");

    await _db.close();
    return null;
  }

  _saveStateToDB() async {
    print("Saving state in DB...");

    var dbPath = await _localPath;
    print(dbPath);

    if (_db == null) _db = ObjectDB(dbPath);
    _db.open();

    // save event types
    var storedEventTypes =
        (await _db.find({'classtype': 'EventType'})).map((l) {
      return l['name'];
    });
    print("Stored event types: $storedEventTypes");
    for (var e in _sEventTypes) {
      if (!storedEventTypes.contains(e.name)) {
        _db.insert(e.toMap());
      }
    }

    // save events
    var storedEvents = (await _db.find({'classtype': 'Event'})).map((l) {
      return l['uuid'];
    });
    print("Stored events: $storedEvents");
    _sDateTimeEvents.forEach((d, events) {
      for (var e in events) {
        if (!storedEvents.contains(e.uuid)) {
          _db.insert(e.toMap());
        }
      }
    });

    await _db.close();
  }

  _saveEventTypesToDB() async {
    print("Saving event types in DB...");

    var dbPath = await _localPath;
    print(dbPath);

    if (_db == null) _db = ObjectDB(dbPath);
    _db.open();

    // save event types
    var storedEventTypes =
        (await _db.find({'classtype': 'EventType'})).map((l) {
      return l['name'];
    });
    print("Stored event types: $storedEventTypes");
    for (var e in _sEventTypes) {
      if (!storedEventTypes.contains(e.name)) {
        _db.insert(e.toMap());
      }
    }

    await _db.close();
  }

  _saveEventsToDB() async {
    print("Saving events in DB...");

    var dbPath = await _localPath;
    print(dbPath);

    if (_db == null) _db = ObjectDB(dbPath);
    _db.open();

    // save events
    var storedEvents = (await _db.find({'classtype': 'Event'})).map((l) {
      return l['uuid'];
    });
    print("Stored events: $storedEvents");
    _sDateTimeEvents.forEach((d, events) {
      for (var e in events) {
        if (!storedEvents.contains(e.uuid)) {
          _db.insert(e.toMap());
        }
      }
    });

    await _db.close();
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

    _saveEvent(event, day);
  }

  _saveEvent(Event event, DateTime day) {
    final alreadySaved = _sDateTimeEvents.containsKey(day) &&
        _sDateTimeEvents[day].contains(event);

    setState(() {
      if (!alreadySaved) {
        print("Add $event");
        _sDateTimeEvents.putIfAbsent(day, () => Set<Event>());
        _sDateTimeEvents[day].add(event);
      } else if (_sDateTimeEvents.containsKey(day)) {
        print("Remove $event");
        _sDateTimeEvents[day].remove(event);
      }
    });

    _saveEventsToDB();
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

    _saveEventTypesToDB();

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
