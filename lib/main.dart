import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: EabsensiApp()));
}

class EabsensiApp extends StatelessWidget {
  const EabsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'eAbsensi',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('eAbsensi'))),
    );
  }
}
