import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:signature_demo/signature/color_picker_dialog.dart';
import 'package:signature_demo/signature/pen_size_picker_dialog.dart';
import 'package:signature_demo/signature/signature.dart';

class SignaturePage extends StatefulWidget {
  SignaturePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  double _penSize = 1;
  Color penColor = Colors.black;
  Color backgroundColor = Colors.white;

  SignatureController _controller;
  GlobalKey _globalKey = new GlobalKey();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          _buildActionsMenu(),
        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: _buildSignatureWidget(),
          ),
        ],
      ),
    );
  }

  _buildSignatureWidget() {
    return Signature(
      controller: _controller,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      backgroundColor: backgroundColor,
    );
  }

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

  _showMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showPenSizePickerDialog() async {
    final selectedPenSize = await showDialog<double>(
      context: context,
      builder: (context) => PenSizePickerDialog(initialPenSize: _penSize),
    );
    if (selectedPenSize != null) {
      setState(() {
        _controller.penColor = penColor;
        _penSize = selectedPenSize;
        _controller.penStrokeWidth = _penSize;
      });
    }
  }

  void _showPenColorPickerDialog() async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(initialColor: penColor),
    );
    if (selectedColor != null) {
      setState(() {
        penColor = selectedColor;
        _controller.penColor = penColor;
      });
    }
  }

  void _showBackgroundColorPickerDialog() async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(initialColor: penColor),
    );
    if (selectedColor != null) {
      setState(() {
        backgroundColor = selectedColor;
      });
    }
  }

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
}
