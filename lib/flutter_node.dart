import 'dart:async';

import 'package:flutter/services.dart';

class FlutterNode {
  static const MethodChannel _channel =
      const MethodChannel('flutter_node');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
