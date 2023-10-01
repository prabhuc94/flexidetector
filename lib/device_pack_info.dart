import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DevicePackageInfo {

  static final DevicePackageInfo _instance = DevicePackageInfo._internal();
  factory DevicePackageInfo () => _instance;
  DevicePackageInfo._internal();

  BaseDeviceInfo? _deviceInfo;
  PackageInfo? _packageInfo;
  String get userName => "${Platform.environment['USERNAME']}";
  String get deviceName => Platform.localHostname;
  String get deviceId => "${_deviceInfo?.data[_isMacOs ? 'systemGUID' : 'deviceId'].toString().replaceAll("{", "").replaceAll("}", "")}";
  String get OS => Platform.operatingSystemVersion;
  String get version => "${_packageInfo?.version}";
  String get ogVersion => "${_packageInfo?.version}";
  String get appName => "${_packageInfo?.appName}";
  String get packageName => "${_packageInfo?.packageName}";

  bool get _isMacOs => Platform.isMacOS;

  void initialize() async {
    _deviceInfo ??= await DeviceInfoPlugin().deviceInfo;
    _packageInfo ??= await PackageInfo.fromPlatform();
  }

  Map<String, dynamic> toMap() => {
    "USERNAME" : userName,
    "DEVICENAME" : deviceName,
    "DEVICEID" : deviceId,
    "OS" : OS,
    "APPNAME" : appName,
    "VERSION" : version,
    "PACKAGENAME" : packageName
  };

}