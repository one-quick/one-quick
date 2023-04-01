import 'package:flutter/services.dart';

class WebSocketServiceAdvertiser {
  static const MethodChannel _channel = MethodChannel('com.example.socket_app/WebSocketAdvertiser');

  static Future<void> registerService(int port) async {
    await _channel.invokeMethod('registerService', {'port': port});
  }

  static Future<void> unregisterService() async {
    await _channel.invokeMethod('unregisterService');
  }
}
