import 'package:flutter/services.dart';

class FlutterNetworkTypePlugin {
  static const MethodChannel _channel = MethodChannel('network_type_plugin');

  static Future<String> getNetworkType({
    String? url,
    double? speedThreshold,
    int? maxRetries,
    double? retryDelay,
    double? timeout,
  }) async {
    final Map<String, dynamic> params = {
      'url': url,
      'speedThreshold': speedThreshold,
      'maxRetries': maxRetries,
      'retryDelay': retryDelay,
      'timeout': timeout,
    };
    final String networkType = await _channel.invokeMethod('getNetworkType', params);
    return networkType;
  }
}
