# Flutter Network Type Plugin

[![Pub Version](https://img.shields.io/pub/v/flutter_network_type_plugin)](https://pub.dev/packages/flutter_network_type_plugin)
[![GitHub license](https://img.shields.io/github/license/yourusername/flutter_network_type_plugin)](https://github.com/yourusername/flutter_network_type_plugin/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/yourusername/flutter_network_type_plugin)](https://github.com/yourusername/flutter_network_type_plugin/stargazers)

A Flutter plugin to determine the network type and measure network speed.

## Features

- Detects the network type (e.g., 4G, 3G, 2G).
- Measures network speed and confirms if the network type is correctly detected.

## Installation

Add `flutter_network_type_plugin` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_network_type_plugin: ^0.0.1
Then run flutter pub get to install the package.

Usage

Example
dart
Copy code
import 'package:flutter/material.dart';
import 'package:flutter_network_type_plugin/flutter_network_type_plugin.dart';

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
API
Future<String> getNetworkType({String? url, double? speedThreshold, int? maxRetries, double? retryDelay, double? timeout})

Fetches the network type. Optionally, you can provide a URL to test the speed and a speed threshold to confirm the network type.

url (String, optional): The URL to use for the speed test.
speedThreshold (double, optional): The speed threshold in Mbps to confirm the network type.
maxRetries (int, optional): The maximum number of retries for the speed test. Default is 0.
retryDelay (double, optional): The delay between retries in seconds. Default is 1.0.
timeout (double, optional): The timeout for the speed test in seconds. Default is 5.0.
Testing
Run the tests to ensure everything is working correctly:

sh
Copy code
flutter test
flutter drive --target=test_driver/app.dart
Contributing
Contributions are welcome! Please see CONTRIBUTING.md for details.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Support

If you encounter any issues or have questions, feel free to open an issue on GitHub.

Author
Developed by Your Name - Your Website

Happy coding!