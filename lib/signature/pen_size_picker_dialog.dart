import 'package:flutter/material.dart';

class PenSizePickerDialog extends StatefulWidget {
  /// initial selection for the slider
  final double initialPenSize;

  const PenSizePickerDialog({Key key, this.initialPenSize}) : super(key: key);

  @override
  _PenSizePickerDialogState createState() => _PenSizePickerDialogState();
}

class _PenSizePickerDialogState extends State<PenSizePickerDialog> {
  /// current selection of the slider
  double _penSize;

  @override
  void initState() {
    super.initState();
    _penSize = widget.initialPenSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pen Size'),
      content: SingleChildScrollView(
        child: Container(
          child: Slider(
            value: _penSize,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _penSize = value;
              });
            },
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _penSize);
          },
          child: Text('Save'),
        )
      ],
    );
  }
}