import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
  String altAccText = "-";
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
        altAccText = "Accuracy: ${formatAltitude(value.altitudeAccuracy, 2)}";
        altAcc = value.altitudeAccuracy;
        errorText = "";
        counter++;
      });
    } catch (err) {
      setState(() {
        errorText = "$err";
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
    double width = 0;
    Color color = Colors.white12;
    if (altAcc > 20) {
      width = 300;
    } else {
      double v = (altAcc) / 20;
      //v = 0.1;
      width = v * 300 + 50;
      color = Color.fromARGB(255, 0, ((1 - v) * 255).round(), 0);
    }
    if (errorText != "") {
      color = Colors.red;
    }
    return Column(
      children: [
        Container(height: 10, width: width, color: color),
        Container(height: 1, width: 300, color: Colors.white30),
      ],
    );
  }

  Widget buildButtons(BuildContext context) {
    return Container(
      height: 70,
      //color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                uom = UOM_METERS;
              });
            },
            child: SizedBox(
              width: 100,
              child: Center(
                child: Text(
                  "METERS",
                  style: TextStyle(
                    color: uom == UOM_METERS ? Colors.green : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                uom = UOM_FEET;
              });
            },
            child: SizedBox(
              width: 100,
              child: Center(
                child: Text(
                  "FEET",
                  style: TextStyle(
                      color: uom == UOM_FEET ? Colors.green : Colors.grey,
                      fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        shadowColor: Colors.blue,
        title: const Text(
          "KISS Altimeter",
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50),
              child: Container(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        formatAltitude(alt, 0),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 96,
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
                  ],
                ),
              ),
            ),
            Column(
              children: [
                accWidget(context),
                Text(
                  altAccText,
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 8),
            ),
            buildButtons(context),
            const Center(
              child: Text(
                "Copyright (c), Poluianov Ivan, 2023",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
