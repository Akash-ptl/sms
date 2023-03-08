import 'package:flutter/services.dart';

class Constants {
  static const int sim = 0;
  static const String androidChannel = "com.example.sms";
  static const MethodChannel nativeChannel = MethodChannel(androidChannel);
}
