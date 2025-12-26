# Flutter Network Type Plugin

[![Pub Version](https://img.shields.io/pub/v/flutter_network_type_plugin)](https://pub.dev/packages/flutter_network_type_plugin)
[![GitHub license](https://img.shields.io/github/license/nurshat13/flutter_network_type_plugin)](https://github.com/nurshat13/flutter_network_type_plugin/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/nurshat13/flutter_network_type_plugin)](https://github.com/nurshat13/flutter_network_type_plugin/stargazers)

A Flutter plugin to determine the network type and measure network speed.

## Features

- Detects the network type: **WiFi**, **5G**, **4G/4G+**, **3G**, **2G**, or **No Internet**
- **WiFi detection** on both iOS and Android
- **5G network support** with immediate detection
- **Optional speed testing** - only runs when both `url` and `speedThreshold` are provided
- Measures network speed and confirms if the network type is correctly detected
- Returns "WiFi (Slow)" or "3G or less" when speed is below threshold

## Installation

Add `flutter_network_type_plugin` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_network_type_plugin: ^0.2.1
```
### Then run flutter pub get to install the package.

## Usage

### Example

```dart
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
      // Simple usage - just get the network type (WiFi, 5G, 4G, 3G, 2G)
      networkType = await FlutterNetworkTypePlugin.getNetworkType();
      
      // Or with speed verification (optional)
      // networkType = await FlutterNetworkTypePlugin.getNetworkType(
      //   url: 'https://www.google.com', // URL for speed test
      //   speedThreshold: 5.0, // Speed threshold in Mbps
      // );
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
```
### API
```dart
Future<String> getNetworkType({
  String? url,
  double? speedThreshold,
  int? maxRetries,
  double? retryDelay,
  double? timeout,
})
```

Fetches the network type. Speed testing is **optional** and only runs when both `url` and `speedThreshold` are provided.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `url` | `String?` | `null` | The URL to use for the speed test. Required for speed verification. |
| `speedThreshold` | `double?` | `null` | The speed threshold in Mbps. Required for speed verification. |
| `maxRetries` | `int?` | `0` | Maximum number of retries for network detection. |
| `retryDelay` | `double?` | `1.0` | Delay between retries in seconds. |
| `timeout` | `double?` | `5.0` | Timeout for the speed test in seconds. |

#### Return Values

| Value | Description |
|-------|-------------|
| `"WiFi"` | Connected via WiFi |
| `"WiFi (Slow)"` | Connected via WiFi but below speed threshold |
| `"5G"` | Connected via 5G cellular |
| `"4G+"` | Connected via LTE-Advanced (Android only) |
| `"4G"` | Connected via LTE/4G cellular |
| `"3G"` | Connected via 3G cellular |
| `"3G or less"` | 4G detected but speed below threshold |
| `"2G"` | Connected via 2G cellular |
| `"NO INTERNET"` | No network connection |
| `"Unknown"` | Unable to determine network type |
| `"Permission required"` | Android: READ_PHONE_STATE permission needed |
### Testing
Run the tests to ensure everything is working correctly:

flutter test
flutter drive --target=test_driver/app.dart
Contributing
Contributions are welcome! Please see CONTRIBUTING.md for details.

### License
This project is licensed under the MIT License - see the LICENSE file for details.

### Support
If you encounter any issues or have questions, feel free to open an issue on GitHub.

### Author
Developed by Nurshat - nurshat170@gmail.com

## Happy coding!
