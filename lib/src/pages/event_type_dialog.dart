import 'package:flutter/material.dart';
import '../base/base_classes.dart';
import '../widgets/icon_picker.dart';
import '../widgets/color_picker.dart';

//void main() => runApp(EventTypeDialogRunner());
//
//func(name, icon, color) {
//  print(name + icon.toString() + color.toString());
//}
//
//class EventTypeDialogRunner extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//        title: 'Event Type Dialog', home: EventTypeDialog(onSubmit: func));
//  }
//}

typedef EventTypeDialogCallback(EventType eventType);

class EventTypeDialog extends StatefulWidget {
  final EventTypeDialogCallback onSubmit;

  EventTypeDialog({this.onSubmit});

  @override
  State createState() => _EventTypeDialogState(onSubmit);
}

class _EventTypeDialogState extends State<EventTypeDialog> {
  String _name = "";
  static final _defaultColor = Colors.blueGrey;
  Color _color = _defaultColor;
  Icon _icon = Icon(Icons.brightness_1);

  final EventTypeDialogCallback onSubmit;

  _EventTypeDialogState(this.onSubmit);

  @override
  Widget build(BuildContext context) {
    return _createNewEventTypeDialog(context);
  }

  _onIconSelect(Icon icon) {
    setState(() {
      _icon = icon;
    });
  }

  _onNameSaved(String name) {
    setState(() {
      _name = name;
    });
  }

  _onColorSelect(Color color) {
    setState(() {
      _color = color;
    });
  }

  Widget _createNewEventTypeDialog(context) {
    print("Create new event dialog");
    return SimpleDialog(
//            title: const Text('Select assignment'),
      children: <Widget>[
        Row(children: [
          Expanded(
              flex: 3,
              child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    decoration:
                        InputDecoration(hintText: "Give event type..."),
                    onChanged: _onNameSaved,
                  ))),
          Expanded(
              flex: 1,
              child:
                  _icon != null ? Icon(_icon.icon, color: _color) : Container())
        ]),
        IconPicker(
          onClickFunction: _onIconSelect,
          width: 200.0,
          height: 180.0,
          color: _defaultColor,
          columns: 5,
          edgeInsets: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        Container(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: ColorBoxGroup(
              width: 25.0,
              height: 25.0,
              spacing: 10.0,
              colors: [
//            themeData.textTheme.display1.color,
                Colors.red,
                Colors.orange,
                Colors.green,
                Colors.purple,
                Colors.blue,
                Colors.yellow,
              ],
              onTap: _onColorSelect,
            ))),
        FlatButton(
          onPressed: () {
            print("submit");
            if (_name != "")
              onSubmit(EventType(_name, _color, _icon.icon));
          },
          child: Text("Submit"),
        )
      ],
    );
  }
}
