import 'package:flutter/services.dart';

class MockLocationService {
  static const _channel = MethodChannel('com.ameth.seguridad/security');

  static Future<bool> isFakeGpsInstalled() async {
    try {
      return await _channel.invokeMethod<bool>('isFakeGpsInstalled') ?? false;
    } on PlatformException {
      return false;
    }
  }
}
