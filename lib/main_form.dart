import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'back_painter.dart';

class MainForm extends StatefulWidget {
  const MainForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainFormState();
  }
}

class MainFormState extends State<MainForm> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      update();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  String altText = "...";
  String errorText = "";
  int counter = 0;
  double alt = 0;
  double altAcc = 0;

  static const int UOM_METERS = 0;
  static const int UOM_FEET = 1;
  int uom = UOM_METERS;

  String formatAltitude(double alt, int prec) {
    double val = alt;
    if (uom == UOM_FEET) {
      val = alt * 3.28084;
    }
    return val.toStringAsFixed(prec);
  }

  void update() async {
    try {
      var value = await _determinePosition();
      setState(() {
        alt = value.altitude;
        altAcc = value.altitudeAccuracy;
        //alt = 42;
        //altAcc = 2.42;
        errorText = "";
        counter++;
      });
    } catch (err) {
      setState(() {
        errorText = "Waiting for location";
        counter--;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Widget accWidget(BuildContext context) {
    int count = (altAcc / 2).round();
    if (count > 8) {
      count = 8;
    }
    if (count < 2) {
      count = 2;
    }
    Color col = const Color.fromARGB(255, 150, 150, 150);
    if (altAcc < 20) {
      col = Colors.orange;
    }
    if (altAcc < 15) {
      col = Colors.yellow;
    }
    if (altAcc < 10) {
      col = Colors.lightGreen;
    }
    if (altAcc < 5) {
      col = Colors.green;
    }

    var st = TextStyle(
      fontSize: 16,
      fontFamily: "Courier New",
      fontWeight: FontWeight.bold,
      color: col,
    );

    List<Widget> items = [
      Text("▪", style: st),
    ];

    for (int i = 0; i < count; i++) {
      items.insert(0, Text("▪", style: st));
    }
    for (int i = 0; i < count; i++) {
      items.add(Text("▪", style: st));
    }

    items.insert(
        0,
        Text(
          "-",
          style: st,
        ));
    items.add(Text(
      "-",
      style: st,
    ));

    return FittedBox(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items,
        ),
      ),
    );
  }

  Widget buildButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: ToggleButtons(
        selectedColor: Colors.blue,
        color: Colors.white54,
        fillColor: Colors.blue.withOpacity(0.2),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        isSelected: [uom == UOM_METERS, uom == UOM_FEET],
        onPressed: (index) {
          switch (index) {
            case 0:
              setState(() {
                uom = UOM_METERS;
              });
              break;
            case 1:
              setState(() {
                uom = UOM_FEET;
              });
              break;
          }
        },
        children: [
          Container(
            color: uom == UOM_METERS
                ? Colors.black
                : const Color.fromARGB(255, 20, 20, 20),
            width: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "METERS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                      color: uom == UOM_METERS ? Colors.blue : Colors.white30,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: uom == UOM_FEET
                ? Colors.black
                : const Color.fromARGB(255, 20, 20, 20),
            width: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "FEET",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                      color: uom == UOM_FEET ? Colors.blue : Colors.white30,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildValue() {
    if (errorText.isNotEmpty) {
      return Center(
        child: Text(
          errorText,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 24,
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (BuildContext, BoxConstraints constraints) {
        var padding = min(constraints.minWidth, constraints.minHeight) / 5;
        return Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                width: 1, color: const Color.fromARGB(255, 50, 50, 50)),
          ),
          margin: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Text(
                    "ALTITUDE",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              FittedBox(
                child: Text(
                  formatAltitude(alt, 0),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                uom == UOM_METERS ? "meters" : "feet",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
              Column(
                children: [
                  accWidget(context),
                  Text(
                    "ACCURACY ${formatAltitude(altAcc, 2)}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: BackPainter(),
            child: Container(),
            key: UniqueKey(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Container(child: buildValue()),
              ),
              Center(
                child: buildButtons(context),
              ),
              const Center(
                child: Text(
                  "Copyright (c), Poluianov Ivan, 2023",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
