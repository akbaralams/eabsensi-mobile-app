import 'package:dio/dio.dart';

import '../domain/punch.dart';

/// Bagian multipart untuk punch dan check-in event. Kontrak: foto JPG/PNG,
/// `latitude` dan `longitude` hanya dikirim berpasangan, `accuracy` (meter)
/// menyertai lokasi.
class EvidenceParts {
  const EvidenceParts({
    this.photo,
    this.latitude,
    this.longitude,
    this.accuracy,
  });

  final MultipartFile? photo;
  final double? latitude;
  final double? longitude;
  final int? accuracy;

  static Future<EvidenceParts> from(EvidenceSubmission e) async {
    final path = e.photoPath;
    final hasFix = e.latitude != null && e.longitude != null;
    return EvidenceParts(
      photo: path == null ? null : await _photo(path),
      latitude: hasFix ? e.latitude : null,
      longitude: hasFix ? e.longitude : null,
      accuracy: hasFix ? e.accuracy : null,
    );
  }

  static Future<MultipartFile> _photo(String path) {
    final png = path.toLowerCase().endsWith('.png');
    return MultipartFile.fromFile(
      path,
      filename: path.split(RegExp(r'[\\/]')).last,
      contentType: DioMediaType('image', png ? 'png' : 'jpeg'),
    );
  }
}
