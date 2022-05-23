import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Custom Painter App",
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class Brush {
  Offset point;
  Paint brush;

  Brush({required this.point, required this.brush});
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double _sliderVal;
  late Color _brushColor;

  List<Brush?> offsets = [];

  _onSliderChanged(double val) {
    setState(() {
      _sliderVal = val;
    });
  }

  void _selectColor() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Color Picker"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _brushColor,
              onColorChanged: (color) {
                setState(() {
                  _brushColor = color;
                });
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("close"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _brushColor = Colors.black;
    _sliderVal = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          //! Background Gradient Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(233, 64, 87, 1.0),
                  Color.fromRGBO(242, 113, 33, 1.0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          //! Paint Section
          //? -> Column
          //? --> 1. Container for Paint
          //? --> 2. Row with different options
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width * .90,
                  height: height * 0.80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onPanDown: (details) {
                      setState(() {
                        offsets.add(
                          Brush(
                              point: details.localPosition,
                              brush: Paint()
                                ..color = _brushColor
                                ..strokeCap = StrokeCap.round
                                ..strokeWidth = _sliderVal),
                        );
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        offsets.add(
                          Brush(
                            point: details.localPosition,
                            brush: Paint()
                              ..color = _brushColor
                              ..strokeCap = StrokeCap.round
                              ..strokeWidth = _sliderVal,
                          ),
                        );
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        offsets.add(null);
                      });
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: CustomPaint(
                        painter: MyCustomPainter(
                          strokeWidth: _sliderVal,
                          offsets: offsets,
                          color: _brushColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: height * 0.08,
                  width: width * .9,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //! Color Picker Button
                      //! Slider (for stroke width)
                      //! another button for something else
                      IconButton(
                        onPressed: _selectColor,
                        icon: Icon(
                          Icons.color_lens,
                          color: _brushColor,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _sliderVal,
                          onChanged: (val) => _onSliderChanged(val),
                          min: 1,
                          max: 10,
                          activeColor: _brushColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            offsets.clear();
                          });
                        },
                        icon: const Icon(Icons.layers_clear),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final double strokeWidth;
  final Color? color;
  final List<Brush?> offsets;
  MyCustomPainter({
    required this.strokeWidth,
    this.color,
    required this.offsets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint rectPaint = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, rectPaint);
    for (int i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        Paint brush = offsets[i]!.brush;
        canvas.drawLine(offsets[i]!.point, offsets[i + 1]!.point, brush);
      } else if (offsets[i] == null && offsets[i + 1] == null) {
        Paint brush = offsets[i]!.brush;
        canvas.drawPoints(PointMode.points, [offsets[i]!.point], brush);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
