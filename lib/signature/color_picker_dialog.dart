import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  /// initial selection for color
  final Color initialColor;

  const ColorPickerDialog({Key key, this.initialColor}) : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  /// current color
  Color _color;
  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Color Picker'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ColorPicker(
              pickerColor: _color,
              onColorChanged: (color) {
                _color = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _color);
          },
          child: Text('Save'),
        )
      ],
    );
  }
}