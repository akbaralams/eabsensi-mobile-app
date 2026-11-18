import 'package:flutter/services.dart';

import '../domain/location.dart';

/// Deteksi root dari sisi Android (`MainActivity.kt`). Gagal memeriksa dianggap
/// tidak terdeteksi: sinyal ini tidak boleh menghalangi absen.
class PlatformDeviceIntegrityService implements DeviceIntegrityService {
  const PlatformDeviceIntegrityService();

  static const _channel = MethodChannel('id.eabsensi.app/device_integrity');

  @override
  Future<bool> isRooted() async {
    try {
      return await _channel.invokeMethod<bool>('isRooted') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

/// Mode mock dan test: perangkat dianggap utuh.
class FakeDeviceIntegrityService implements DeviceIntegrityService {
  const FakeDeviceIntegrityService({this.rooted = false});

  final bool rooted;

  @override
  Future<bool> isRooted() async => rooted;
}
