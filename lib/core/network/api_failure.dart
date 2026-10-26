/// Galat dari lapisan data, dipetakan dari kontrak API:
/// 401 -> [UnauthenticatedFailure], 403 -> [ForbiddenFailure],
/// 422 `message` saja -> [RuleRejectedFailure], 422 `errors` -> [ValidationFailure],
/// 429 -> [TooManyRequestsFailure], tanpa jaringan -> [OfflineFailure].
sealed class ApiFailure implements Exception {
  const ApiFailure();

  /// Teks yang aman ditampilkan ke pengguna.
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Token tidak ada, kedaluwarsa, atau dicabut: hapus token dan kembali ke login.
final class UnauthenticatedFailure extends ApiFailure {
  const UnauthenticatedFailure();

  @override
  String get message => 'Sesi berakhir. Silakan masuk kembali.';
}

final class ForbiddenFailure extends ApiFailure {
  const ForbiddenFailure(this.message);

  @override
  final String message;
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

final class TooManyRequestsFailure extends ApiFailure {
  const TooManyRequestsFailure();

  @override
  String get message =>
      'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
}

final class OfflineFailure extends ApiFailure {
  const OfflineFailure();

  @override
  String get message =>
      'Absen membutuhkan jaringan karena waktu dicatat oleh server. '
      'Sambungkan internet lalu coba lagi.';
}

final class UnknownFailure extends ApiFailure {
  const UnknownFailure([this.message = 'Terjadi kesalahan. Coba lagi.']);

  @override
  final String message;
}
