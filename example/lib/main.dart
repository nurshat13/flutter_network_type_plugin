import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_network_type_plugin/network_type_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NetworkCheck(),
    );
  }
}

class NetworkCheck extends StatefulWidget {
  @override
  _NetworkCheckState createState() => _NetworkCheckState();
}

class _NetworkCheckState extends State<NetworkCheck> {
  String _networkType = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getNetworkType();
  }

  Future<void> _getNetworkType() async {
    String networkType;
    try {
      networkType = await FlutterNetworkTypePlugin.getNetworkType(
        url: 'https://www.google.com', // User-defined URL
        speedThreshold: 5.0, // User-defined speed threshold in Mbps
      );
    } on PlatformException catch (e) {
      networkType = "Failed to get network type: '${e.message}'.";
    }
    setState(() {
      _networkType = networkType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Check'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Network Type: $_networkType'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getNetworkType,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
