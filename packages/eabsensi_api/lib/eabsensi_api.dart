// Generated code - do not modify by hand
// ignore_for_file: lines_longer_than_80_chars


/// eAbsensi API mobile
/// Version 1.0.0
/// API untuk aplikasi pegawai (Flutter). Deskripsi naratif dan aturan bisnis ada di `docs/api.md`;
/// perilakunya dijaga suite test kontrak `tests/contract` (Hurl). File ini bentuk mesin dari kontrak
/// yang sama, untuk membangkitkan client dan memeriksa implementasi.
/// 
/// Semua respons JSON. Klien sebaiknya mengirim `Accept: application/json`.
/// Waktu yang dikembalikan selalu ISO 8601 di zona waktu bisnis (`timezone` di profil, default `Asia/Jakarta`).
/// 
/// **Dua bentuk 422.** Galat validasi berisi `message` + `errors` (nama field dijamin, teks pesan informatif).
/// Penolakan aturan bisnis berisi `message` saja; teksnya bagian dari kontrak dan aman ditampilkan apa adanya.
/// 
/// **Batas laju.** Login: 60/menit per IP dan 5/menit per akun+IP. Semua endpoint ber-token: 120/menit per token.
/// Punch, check-in event, dan pengajuan cuti: tambahan 20/menit per pengguna. Melebihi batas: 429.
/// 


library;

export 'src/api_client/auth_api.dart';
export 'src/api_client/cuti_api.dart';
export 'src/api_client/event_api.dart';
export 'src/api_client/punch_api.dart';
export 'src/model/auth_login_post422_body_any_of_model.dart';
export 'src/model/employee_summary.dart';
export 'src/model/event.dart';
export 'src/model/event_check_in.dart';
export 'src/model/events_event_check_in_post201_body_model.dart';
export 'src/model/events_get200_body_model.dart';
export 'src/model/evidence_form.dart';
export 'src/model/leave.dart';
export 'src/model/leave_request.dart';
export 'src/model/leave_status_model.dart';
export 'src/model/leaves_get200_body_model.dart';
export 'src/model/leaves_post201_body_model.dart';
export 'src/model/login_request.dart';
export 'src/model/login_response.dart';
export 'src/model/login_v2_response.dart';
export 'src/model/me.dart';
export 'src/model/me_employee_one_of_model.dart';
export 'src/model/me_get200_body_model.dart';
export 'src/model/message.dart';
export 'src/model/option.dart';
export 'src/model/punch.dart';
export 'src/model/punch_source_model.dart';
export 'src/model/punch_status_model.dart';
export 'src/model/punches_get200_body_model.dart';
export 'src/model/punches_post201_body_model.dart';
export 'src/model/refresh_request.dart';
export 'src/model/token_pair.dart';
export 'src/model/unprocessable_body_any_of_model.dart';
export 'src/model/validation_error.dart';
export 'src/response_wrapper/check_in_event_response.dart';
export 'src/response_wrapper/create_leave_response.dart';
export 'src/response_wrapper/create_punch_response.dart';
export 'src/response_wrapper/list_events_response.dart';
export 'src/response_wrapper/list_leaves_response.dart';
export 'src/response_wrapper/list_punches_response.dart';
export 'src/response_wrapper/login_response_wrapper.dart';
export 'src/response_wrapper/login_v2_response_wrapper.dart';
export 'src/response_wrapper/logout_response.dart';
export 'src/response_wrapper/logout_v2_response.dart';
export 'src/response_wrapper/me_operation_response.dart';
export 'src/response_wrapper/refresh_token_response.dart';
export 'src/server/server.dart';
