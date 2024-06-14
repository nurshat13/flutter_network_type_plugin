import 'package:flutter/services.dart';
import 'package:flutter_network_type_plugin/network_type_plugin_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNetworkTypePlugin platform = MethodChannelNetworkTypePlugin();
  const MethodChannel channel = MethodChannel('network_type_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getNetworkType') {
          return 'Mock Network Type';
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getNetworkType', () async {
    expect(await platform.getNetworkType(), 'Mock Network Type');
  });

  test('getNetworkType with parameters', () async {
    expect(
        await platform.getNetworkType(
          url: 'https://www.google.com',
          speedThreshold: 5.0,
          maxRetries: 3,
          retryDelay: 1.0,
          timeout: 5.0,
        ),
        'Mock Network Type');
  });
}
