import 'package:flutter/foundation.dart';

enum PunchStatus { pending, approved, rejected }

@immutable
class Punch {
  const Punch({
    required this.id,
    required this.punchedAt,
    required this.source,
    required this.status,
    required this.statusLabel,
    required this.hasPhoto,
  });

  final int id;

  /// Waktu dari server (zona waktu bisnis).
  final DateTime punchedAt;
  final String source;
  final PunchStatus status;
  final String statusLabel;
  final bool hasPhoto;
}

/// Bukti punch/check-in: foto (bila `requires_photo`) dan lokasi (bila izin).
/// `latitude` dan `longitude` selalu berpasangan.
@immutable
class EvidenceSubmission {
  const EvidenceSubmission({
    this.photoPath,
    this.latitude,
    this.longitude,
    this.accuracy,
  });

  final String? photoPath;
  final double? latitude;
  final double? longitude;

  /// Meter, bilangan bulat.
  final int? accuracy;
}

abstract class PunchRepository {
  /// Punch milik sendiri pada [date], terlama dulu.
  Future<List<Punch>> list(DateTime date);

  /// Catat punch; waktu ditentukan server.
  Future<Punch> create(EvidenceSubmission evidence);
}
