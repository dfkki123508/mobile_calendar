import 'package:flutter/material.dart';

void main() => runApp(IconPickerRunner());

class IconPickerRunner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrolling calendar',
      home: IconPicker(width: 200.0, height: 50.0,),
    );
  }
}

class IconPicker extends StatelessWidget {
  final List<Icon> icons;
  final Function(Icon) onClickFunction;
  final EdgeInsets edgeInsets;
  final Color color;
  final int columns;
  final double width;
  final double height;

  IconPicker(
      {List<Icon> icons, onClickFunction, EdgeInsets edgeInsets, int columns, this.width, this.height, this.color})
      : icons = icons ??
            <Icon>[
              Icon(Icons.calendar_today),
              Icon(Icons.add_photo_alternate),
              Icon(Icons.done_all),
              Icon(Icons.brightness_1),
              Icon(Icons.https),
              Icon(Icons.border_all),
              Icon(Icons.call_split),
              Icon(Icons.fast_forward),
              Icon(Icons.calendar_today),
              Icon(Icons.add_photo_alternate),
              Icon(Icons.done_all),
              Icon(Icons.brightness_1),
              Icon(Icons.https),
              Icon(Icons.border_all),
              Icon(Icons.call_split),
              Icon(Icons.fast_forward),
              Icon(Icons.border_all),
              Icon(Icons.call_split),
              Icon(Icons.fast_forward),
              Icon(Icons.calendar_today),
              Icon(Icons.add_photo_alternate),
              Icon(Icons.done_all),
              Icon(Icons.brightness_1),
              Icon(Icons.https),
              Icon(Icons.border_all),
              Icon(Icons.call_split),
              Icon(Icons.fast_forward),
            ],
        edgeInsets = edgeInsets != null ? edgeInsets : EdgeInsets.all(8.0),
        columns = columns ?? 6,
        onClickFunction = onClickFunction ?? _defaultOnClick;

  static _defaultOnClick(Icon icon) {
    print(icon);
  }

  @override
  Widget build(BuildContext context) {
//    return Scaffold(appBar: AppBar(leading: Text("appbar")), body: _createBody());
    return _createBody();
  }

  Widget _createBody() {
    return Container(
        height: height,
        width: width,
        child: Center(
            child: CustomScrollView(slivers: <Widget>[
          SliverPadding(
              padding: edgeInsets,
              sliver: new SliverGrid.count(
                  crossAxisSpacing: 0.0,
                  crossAxisCount: columns,
                  children: _buildIconUI()))
        ])));
  }

//  Icon _withColor(Icon icon, Color color){
//    return Icon(icon.icon, color: color,);
//  }

  List<Widget> _buildIconUI() {
    return icons
        .map((icon) => GridTile(
            child: new InkResponse(
                enableFeedback: true,
                child: Icon(icon.icon, color: color,),
                onTap: () => onClickFunction(icon))))
        .toList();
  }
}
