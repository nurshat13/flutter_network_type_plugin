import 'package:flutter_network_type_plugin/network_type_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class NetworkTypePluginPlatform extends PlatformInterface {
  NetworkTypePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static NetworkTypePluginPlatform _instance = MethodChannelNetworkTypePlugin();

  static NetworkTypePluginPlatform get instance => _instance;

  static set instance(NetworkTypePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getNetworkType({String? url, double? speedThreshold, int? maxRetries, double? retryDelay, double? timeout}) {
    throw UnimplementedError('getNetworkType() has not been implemented.');
  }
}
