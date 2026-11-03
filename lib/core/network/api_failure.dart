import 'dart:convert';

/// Galat dari lapisan data, dipetakan dari kontrak API (lihat
/// [failureFromResponse]): 401 -> [UnauthenticatedFailure], 403 ->
/// [ForbiddenFailure], 404 -> [NotFoundFailure], 422 `message` saja ->
/// [RuleRejectedFailure], 422 `errors` -> [ValidationFailure], 429 ->
/// [TooManyRequestsFailure], tanpa jaringan/timeout -> [OfflineFailure].
sealed class ApiFailure implements Exception {
  const ApiFailure();

  /// Teks yang aman ditampilkan ke pengguna.
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Token tidak ada, kedaluwarsa, atau dicabut: hapus token dan kembali ke login.
/// [message] berisi pesan server bila sesi diakhiri dengan alasan (mis. refresh
/// token ditolak 403).
final class UnauthenticatedFailure extends ApiFailure {
  const UnauthenticatedFailure([this.message = defaultMessage]);

  static const defaultMessage = 'Sesi berakhir. Silakan masuk kembali.';

  @override
  final String message;
}

final class ForbiddenFailure extends ApiFailure {
  const ForbiddenFailure(this.message);

  @override
  final String message;
}

/// 404: data sudah tidak ada (mis. event dihapus). Pesan umum.
final class NotFoundFailure extends ApiFailure {
  const NotFoundFailure();

  @override
  String get message => 'Data tidak ditemukan. Muat ulang lalu coba lagi.';
}

/// Penolakan aturan bisnis: pesan server ditampilkan apa adanya.
final class RuleRejectedFailure extends ApiFailure {
  const RuleRejectedFailure(this.message);

  @override
  final String message;
}

/// Galat validasi: pesan per field.
final class ValidationFailure extends ApiFailure {
  const ValidationFailure(this.message, this.errors);

  @override
  final String message;
  final Map<String, List<String>> errors;

  String? first(String field) {
    final list = errors[field];
    return list == null || list.isEmpty ? null : list.first;
  }
}

/// 429. [retryAfter] dari header `Retry-After` bila ada. Jangan mengirim ulang
/// otomatis; pengguna yang mencoba lagi.
final class TooManyRequestsFailure extends ApiFailure {
  const TooManyRequestsFailure({this.retryAfter});

  final Duration? retryAfter;

  @override
  String get message {
    final s = retryAfter?.inSeconds;
    return s == null || s <= 0
        ? 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.'
        : 'Terlalu banyak percobaan. Coba lagi dalam $s detik.';
  }
}

final class OfflineFailure extends ApiFailure {
  const OfflineFailure();

  @override
  String get message =>
      'Absen membutuhkan jaringan karena waktu dicatat oleh server. '
      'Sambungkan internet lalu coba lagi.';
}

final class UnknownFailure extends ApiFailure {
  const UnknownFailure([this.message = defaultMessage]);

  static const defaultMessage = 'Terjadi kesalahan. Coba lagi.';
  static const payloadTooLarge = 'Ukuran foto terlalu besar.';
  static const serverBusy = 'Server sedang sibuk. Coba lagi sebentar lagi.';

  @override
  final String message;
}

/// Petakan respons galat (status, header `Retry-After`, body mentah) ke
/// [ApiFailure]. [body] boleh berupa byte, string, atau JSON hasil decode.
/// Status yang maknanya cukup dari kodenya (401, 404, 413, 429, 503) tidak
/// butuh body JSON; 403 dan 422 butuh `message` dari body JSON.
ApiFailure failureFromResponse(
  int? status, {
  String? retryAfter,
  Object? body,
}) {
  switch (status) {
    case 401:
      return const UnauthenticatedFailure();
    case 404:
      return const NotFoundFailure();
    case 413:
      return const UnknownFailure(UnknownFailure.payloadTooLarge);
    case 429:
      return TooManyRequestsFailure(retryAfter: _retryAfter(retryAfter));
    case 503:
      return const UnknownFailure(UnknownFailure.serverBusy);
  }
  final json = _decodeJson(body);
  if (json is! Map<String, Object?>) return const UnknownFailure();
  final message = json['message'];
  switch (status) {
    case 403:
      return message is String && message.isNotEmpty
          ? ForbiddenFailure(message)
          : const UnknownFailure();
    case 422:
      final errors = json['errors'];
      if (errors is Map<String, Object?>) {
        return ValidationFailure(
          message is String ? message : 'Data yang diberikan tidak valid.',
          {
            for (final e in errors.entries)
              e.key: [
                if (e.value is List<Object?>)
                  for (final m in e.value! as List<Object?>)
                    if (m is String) m,
              ],
          },
        );
      }
      return message is String && message.isNotEmpty
          ? RuleRejectedFailure(message)
          : const UnknownFailure();
  }
  return const UnknownFailure();
}

Duration? _retryAfter(String? header) {
  final seconds = int.tryParse(header?.trim() ?? '');
  return seconds == null ? null : Duration(seconds: seconds);
}

Object? _decodeJson(Object? body) {
  try {
    return switch (body) {
      final List<int> bytes => jsonDecode(utf8.decode(bytes)),
      final String text => jsonDecode(text),
      _ => body,
    };
  } on FormatException {
    return null;
  }
}
