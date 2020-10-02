import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic _ledChar;
  //var _myService = "bb89ad38-c3a8-4e49-8c9f-b15573ee9a70";
  var _myService = "1d88ef03-2083-4603-86bf-7965794b1ea0";
  //var _myChar = "a404a877-90d8-44ae-af73-92a17ede3d11";
  var _myChar = "02e05359-0f7f-4020-bf3a-a7cd1a3b05ab";

  bool _getLEDChar(List<BluetoothService> services) {
    for (BluetoothService s in services) {
      if (s.uuid.toString() == _myService) {
        var characteristics = s.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == _myChar) {
            _ledChar = c;
            print("found service / characteristic !! ----------------------");
            return true;
          }
        }
      }
    }
    return false;
  }

  void _connectDevice(BluetoothDevice device) async {
    flutterBlue.stopScan();
    try {
      await device.connect();
    } catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      List<BluetoothService> services = await device.discoverServices();
      _getLEDChar(services);
    }
  }

  void _scanForDevice() {
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name == "barbud") {
          _connectDevice(result.device);
        }
      }
    });

    flutterBlue.startScan();
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
            FloatingActionButton(
              onPressed: () async {
                await _ledChar.setNotifyValue(true);
                _ledChar.value.listen((value) {
                  print("DOUBLE CLICK DETECTED !!!!!!!! -------------------");
                });
              },
              tooltip: 'Increment',
              child: Icon(Icons.add_circle),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanForDevice,
        tooltip: 'Increment',
        child: Icon(Icons.bluetooth_searching),
      ),
    );
  }
}
