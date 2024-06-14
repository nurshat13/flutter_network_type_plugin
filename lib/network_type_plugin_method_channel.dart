import 'package:flutter/services.dart';
import 'network_type_plugin_platform_interface.dart';

class MethodChannelNetworkTypePlugin extends NetworkTypePluginPlatform {
  static const MethodChannel _channel = MethodChannel('network_type_plugin');

  @override
  Future<String> getNetworkType({
    String? url,
    double? speedThreshold,
    int? maxRetries,
    double? retryDelay,
    double? timeout,
  }) async {
    final String networkType = await _channel.invokeMethod('getNetworkType', {
      'url': url,
      'speedThreshold': speedThreshold,
      'maxRetries': maxRetries,
      'retryDelay': retryDelay,
      'timeout': timeout,
    });
    return networkType;
  }
}
