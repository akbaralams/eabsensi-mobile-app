import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

const _key = 'device_name';

/// `device_name` stabil per instalasi: satu token per perangkat, login ulang
/// menggantikan token lama. Dibuat sekali lalu disimpan.
Future<String> stableDeviceName(SharedPreferences prefs) async {
  final saved = prefs.getString(_key);
  if (saved != null && saved.isNotEmpty) return saved;
  final rnd = Random.secure();
  final suffix = List.generate(
    8,
    (_) => rnd.nextInt(16).toRadixString(16),
  ).join();
  final name = 'eabsensi-android-$suffix';
  await prefs.setString(_key, name);
  return name;
}
