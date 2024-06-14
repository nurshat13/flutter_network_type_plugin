// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:network_type_plugin/network_type_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getNetworkType test', (WidgetTester tester) async {
    // Test with default parameters
    final String networkType = await FlutterNetworkTypePlugin.getNetworkType();
    expect(networkType.isNotEmpty, true);

    // Test with custom URL and speed threshold
    final String customNetworkType = await FlutterNetworkTypePlugin.getNetworkType(
      url: 'https://www.google.com',
      speedThreshold: 5.0,
    );
    expect(customNetworkType.isNotEmpty, true);
  });
}
