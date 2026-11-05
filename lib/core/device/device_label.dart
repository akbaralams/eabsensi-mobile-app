import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nama HP yang dikenali pegawai (mis. "Galaxy A54 5G"), hanya untuk
/// tampilan. Identitas perangkat untuk login tetap `device_name` acak per
/// instalasi; nama ini tidak dikirim ke server.
final deviceLabelProvider = FutureProvider<String?>((ref) async {
  try {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      return deviceLabel(
        name: a.name,
        manufacturer: a.manufacturer,
        model: a.model,
      );
    }
    if (Platform.isIOS) {
      final i = await info.iosInfo;
      return deviceLabel(name: i.modelName);
    }
  } on Object {
    // Plugin tidak ada (test, platform lain): tampil ID perangkat saja.
  }
  return null;
});

/// Nama perangkat dari Setelan bila ada, selain itu merek + model
/// ("Samsung SM-A546E"); merek tidak diulang bila model sudah memuatnya.
String? deviceLabel({String? name, String? manufacturer, String? model}) {
  final n = name?.trim() ?? '';
  if (n.isNotEmpty) return n;
  final m = model?.trim() ?? '';
  final brand = manufacturer?.trim() ?? '';
  if (m.isEmpty) return brand.isEmpty ? null : _capitalize(brand);
  if (brand.isEmpty || m.toLowerCase().startsWith(brand.toLowerCase())) {
    return m;
  }
  return '${_capitalize(brand)} $m';
}

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
