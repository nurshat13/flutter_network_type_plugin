import 'package:flutter_network_type_plugin/network_type_plugin.dart';
import 'package:flutter_network_type_plugin/network_type_plugin_method_channel.dart';
import 'package:flutter_network_type_plugin/network_type_plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNetworkTypePluginPlatform with MockPlatformInterfaceMixin implements NetworkTypePluginPlatform {
  @override
  Future<String> getNetworkType(
      {String? url, double? speedThreshold, int? maxRetries, double? retryDelay, double? timeout}) {
    return Future.value('Mock Network Type');
  }
}

void main() {
  final NetworkTypePluginPlatform initialPlatform = NetworkTypePluginPlatform.instance;

  test('$MethodChannelNetworkTypePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNetworkTypePlugin>());
  });

  test('getNetworkType', () async {
    MockNetworkTypePluginPlatform fakePlatform = MockNetworkTypePluginPlatform();
    NetworkTypePluginPlatform.instance = fakePlatform;

    expect(await FlutterNetworkTypePlugin.getNetworkType(), 'Mock Network Type');
  });

  test('getNetworkType with parameters', () async {
    MockNetworkTypePluginPlatform fakePlatform = MockNetworkTypePluginPlatform();
    NetworkTypePluginPlatform.instance = fakePlatform;

    expect(await FlutterNetworkTypePlugin.getNetworkType(url: 'https://www.google.com', speedThreshold: 5.0),
        'Mock Network Type');
  });
}
