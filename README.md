# Signature Demo

An implementation of `signature` package to draw on screen.

https://user-images.githubusercontent.com/66630141/120439810-96f8bf00-c3a0-11eb-86aa-f258b327f131.mov


Hey guys! Today we are going to learn about **signature** package in flutter.

A Flutter plugin providing performance optimized signature canvas with ability to set custom style, boundaries and initial state. This is native flutter implementation, so it supports all platforms.

        #signature
        #“A free hand drawing tool”

We will be building a simple `Signature` app. In this we will be drawing something on the screen and saving it. Just a small app only for demonstration. No high expectations please. Haha!

Lets begin!!!

## Step 1 :  Install Packages

Place the below dependencies in your `pubspec.yaml` file and run `flutter pub get`
```

  signature: ^4.1.1

```

This is the main package for demonstration but we will add a few more to add some functionalitites to our app.

```

  fluttertoast: ^8.0.7
  esys_flutter_share: ^1.0.2
  flutter_colorpicker: ^0.4.0

```


## Step 2 : Declare your variables

We will be needing a few variables as shown below which are self explanatory.

```dart
  double _penSize = 1;
  Color penColor = Colors.black;
  Color backgroundColor = Colors.white;

  SignatureController _controller;
  GlobalKey _globalKey = new GlobalKey();
```

## Step 3 : Initialize variables

The `SignatureController` needs to be initialized in the `initState` method as shown below.

```dart
@override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: _penSize,
      penColor: penColor,
      exportBackgroundColor: backgroundColor,
    );
    _controller.addListener(() => print('Value changed'));
  }
```

## Step 4 : Create UI for Signature widget

Now that we have declared and initialized our variables, lets go ahead and create our UI.

```dart
 _buildSignatureWidget() {
    return Signature(
      controller: _controller,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      backgroundColor: backgroundColor,
    );
  }
```
We have taken the full height and width for our `drawing board -> Signature` widget. We have asssigned the initialized signaturecontroller to it.

And its done. Thats all for the basic demo of a signature app. You will now be able to draw on the screen. But as you know we will be adding some flavors to our app lets keep going with the flow.

## Step 5 : Create ColorPicker and PenSizePicker dialog

First we create a file `pen_size_picker_dialog.dart`. With the help of this dialog we will be dynamically changing the pen stroke width of our signature.

```dart
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
```

Now that we have controlled our pen size let us jump to controlling colors of signature and background. Lets create a file named `color_picker_dialog.dart`

```dart
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
```

## Step 6 : Creating Action Popup Menu

We will be having some actions menu to control the elements we defined above.

```dart
_buildActionsMenu() {
return PopupMenuButton(
  itemBuilder: (BuildContext bc) => [
    PopupMenuItem(child: Text("Pen Size"), value: "1"),
    PopupMenuItem(child: Text("Pen Color"), value: "2"),
    PopupMenuItem(child: Text("Background Color"), value: "3"),
    PopupMenuItem(child: Text("Save"), value: "4"),
    PopupMenuItem(child: Text("Clear"), value: "5"),
  ],
  onSelected: (route) {
    print(route);
    switch (route) {
      case "1":
        _showPenSizePickerDialog();
        break;
      case "2":
        _showPenColorPickerDialog();
        break;
      case "3":
        _showBackgroundColorPickerDialog();
        break;
      case "4":
        _saveAndShareSignature();
        break;
      case "5":
        _controller.clear();
        break;
    }
  },
);
}
```

## Step 7 : Sharing the signature

Now that we have controlled the elements of our signature like penSize, penColor, backgroundColor, lets see how we can share this signature as image. (.png). First warp the signature widget with `RepaintBoundary` widget and provide it the globalKey declared in step 2.

```dart
RepaintBoundary(
        key: _globalKey,
        child: _buildSignatureWidget(),
      ),
```

Now for saving the image to `ByteData` and sharing it we are using the `esys_esys_flutter_share`. First it will convert the widget into a `ByteData`. Then that ByteData is converted into `Unit8List` and later these bytes are shared into .png format. Lets dive into it.

```dart
void _saveAndShareSignature() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      _shareImage(pngBytes);
      setState(() {});
    } catch (e) {
      print(e);
      _showMessage("Error Occured.");
    }
  }

  Future<void> _shareImage(Uint8List bytes) async {
    try {
      await Share.file('Share Via', 'signature.png', bytes, 'image/png',
          text: 'My Signature');
    } catch (e) {
      print('error: $e');
    }
  }
```
This will save the image in Unit8List and open the share intent for you. Now you can select the app in which you want to share this image.


That's it folks! We're done with all the coding. Just go ahead and run your app!

Fantastic!! You have just learned how to create a signature on or simply draw on screen.

## Important:

This repository is only for providing information on `signature`. Please do not misuse it.

## Author:

* [Amit Mishra](https://github.com/amitmishra7)

If you like this tutorial please don't forget to add a **Star**. Also follow to get informed for upcoming tutorials.
