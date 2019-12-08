import 'package:flutter/material.dart';
import 'package:flutter_android/android_hardware.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study 001',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Study 001'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _stepCountValue = 'Unknown';
  StreamSubscription<int> _subscription;

  void _onData(int stepCountValue) async {
    setState(() {
      _stepCountValue = "$stepCountValue";
    });
  }

  void _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
    });
    await prefs.setInt('counter', _counter);
  }

  Future<void> _initPlatformState() async {
    var sensor =
        await SensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('counter') ?? 0) + 1;

    setState(() {
      _counter = counter;
    });

    var events = await sensor.subscribe();
    events.listen((SensorEvent event) {
      setState(() {
        _incrementCounter();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    setUpPedometer();
  }

  void _onDone() => print("Finished pedometer tracking");

  void _onError(error) => print("Flutter Pedometer Error: $error");

  void setUpPedometer() {
    Pedometer pedometer = new Pedometer();
    _subscription = pedometer.pedometerStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            this._counter % 2 == 0
                ? Image.asset("images/walk_0.png")
                : Image.asset("images/walk_1.png"),
            Text(
              '$_stepCountValue',
              style: Theme.of(context).textTheme.display1,
            ),
            RaisedButton(
              onPressed: () {},
              child: Text("テクポをあげる"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
