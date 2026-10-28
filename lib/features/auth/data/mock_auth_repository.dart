import '../../../core/mock/mock_env.dart';
import '../../../core/network/api_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

/// Password semua akun contoh.
const mockPassword = 'rahasia123';

/// Data dummy yang mengikuti contoh respons di kontrak (`mobile-api.yaml`).
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._env);

  final MockEnv _env;

  static const _employee = EmployeeSummary(
    id: 12,
    employeeNumber: '2010011004',
    name: 'Andi Setiawan',
    department: 'Dinas Komunikasi dan Informatika',
  );

  UserProfile _profile() {
    final s = _env.scenario();
    return UserProfile(
      id: 7,
      name: 'Andi Setiawan',
      username: 'kontrak',
      employee: _employee,
      timezone: 'Asia/Jakarta',
      requiresPhoto: s.requiresPhoto,
      requiresApproval: s.requiresApproval,
      isSupervisor: true,
    );
  }

  Future<void> _network() async {
    await _env.network();
    if (_env.scenario().offline) throw const OfflineFailure();
  }

  @override
  Future<UserProfile> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    await _network();
    final errors = <String, List<String>>{
      if (login.trim().isEmpty) 'login': ['Kolom login wajib diisi.'],
      if (password.isEmpty) 'password': ['Kolom password wajib diisi.'],
    };
    if (errors.isNotEmpty) {
      throw ValidationFailure('Data yang diberikan tidak valid.', errors);
    }
    if (login == 'kontrak.tanpa-pegawai' && password == mockPassword) {
      throw const ForbiddenFailure('Akun ini belum terhubung ke data pegawai.');
    }
    if (login != 'kontrak' || password != mockPassword) {
      // Pesan sama untuk user tidak ada, sandi salah, dan akun nonaktif.
      throw const RuleRejectedFailure('Username atau kata sandi salah.');
    }
    await _env.tokens.write('7|mock-token-$deviceName');
    return _profile();
  }

  @override
  Future<UserProfile> fetchMe() async {
    await _network();
    final token = await _env.tokens.read();
    if (token == null || _env.scenario().tokenRevoked) {
      throw const UnauthenticatedFailure();
    }
    return _profile();
  }

  @override
  Future<void> logout() async {
    await _network();
    await _env.tokens.clear();
  }
}
