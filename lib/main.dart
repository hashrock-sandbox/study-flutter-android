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
      title: 'てくてく活動 誕生日Ver',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MyHomePage(title: 'てくてく活動 ～誕生日Ver～'),
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
  int _stepsFromBoot = 0;
  int _stepsFromBootUsed = 0;
  int _tekupo = 0;

  // String _stepCountValue = 'Unknown';
  StreamSubscription<int> _subscription;

  void _onData(int stepCountValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // _stepCountValue = "$stepCountValue";
      _stepsFromBoot = stepCountValue;
    });
    await saveSharedPrefs(prefs);
  }

  void _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
    });
    await saveSharedPrefs(prefs);
  }

  Future<void> _initPlatformState() async {
    var sensor =
        await SensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('counter') ?? 0) + 1;

    setState(() {
      _counter = counter;
      _stepsFromBoot = (prefs.getInt('stepsFromBoot') ?? 0);
      _stepsFromBootUsed = (prefs.getInt('stepsFromBootUsed') ?? 0);
      _tekupo = (prefs.getInt('tekupo') ?? 0);
    });

    var events = await sensor.subscribe();
    events.listen((SensorEvent event) {
      setState(() {
        _incrementCounter();
      });
    });
  }

  void onUseTekupo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      int diff = _stepsFromBoot - _stepsFromBootUsed;
      _stepsFromBootUsed = _stepsFromBoot;
      _tekupo += diff;
    });
    await saveSharedPrefs(prefs);
  }

  Future saveSharedPrefs(SharedPreferences prefs) async {
    await prefs.setInt('counter', _counter);
    await prefs.setInt('stepsFromBoot', _stepsFromBoot);
    await prefs.setInt('stepsFromBootUsed', _stepsFromBootUsed);
    await prefs.setInt('tekupo', _tekupo);
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
              '$_stepsFromBoot steps',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              '$_tekupo tekupo',
              style: Theme.of(context).textTheme.display1,
            ),
            RaisedButton(
              onPressed: onUseTekupo,
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
