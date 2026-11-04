import 'package:dio/dio.dart';
import 'package:eabsensi/features/update/data/http_update_repository.dart';
import 'package:eabsensi/features/update/domain/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

final _manifest = Uri.parse(
  'https://github.com/akbaralams/eabsensi-mobile-app/releases/latest/download/version.json',
);

Map<String, Object?> _body({String? url}) => {
  'version_name': '1.0.3',
  'version_code': 10003,
  'apk_url': url ?? 'https://github.com/akbaralams/eabsensi-mobile-app/releases/download/v1.0.3/eabsensi-v1.0.3.apk',
  'sha256': 'a' * 64,
};

HttpUpdateRepository _repo(FakeAdapter adapter) =>
    HttpUpdateRepository(Dio()..httpClientAdapter = adapter, _manifest);

void main() {
  test('membaca manifes walau disajikan sebagai octet-stream', () async {
    final adapter = FakeAdapter(
      (r, i) => ResponseBody.fromString(
        '{"version_name":"1.0.3","version_code":10003,'
        '"apk_url":"https://github.com/akbaralams/eabsensi-mobile-app/releases/download/v1.0.3/a.apk",'
        '"sha256":"${'b' * 64}"}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/octet-stream'],
        },
      ),
    );
    final info = await _repo(adapter).latest();
    expect(info!.versionCode, 10003);
    expect(adapter.requests.single.options.uri, _manifest);
  });

  test('tidak mengirim token API ke host manifes', () async {
    final adapter = FakeAdapter((r, i) => jsonBody(200, _body()));
    await _repo(adapter).latest();
    expect(adapter.requests.single.header('Authorization'), isNull);
  });

  test('404 (belum ada rilis) bukan galat: tidak ada pembaruan', () async {
    final adapter = FakeAdapter((r, i) => textBody(404, 'Not Found'));
    expect(await _repo(adapter).latest(), isNull);
  });

  test('tanpa jaringan -> UpdateCheckFailure berpesan jelas', () async {
    final adapter = FakeAdapter((r, i) => offline(r));
    await expectLater(
      _repo(adapter).latest(),
      throwsA(
        isA<UpdateCheckFailure>().having(
          (e) => e.message,
          'message',
          contains('koneksi'),
        ),
      ),
    );
  });

  test('server 500 -> UpdateCheckFailure', () async {
    final adapter = FakeAdapter((r, i) => textBody(500, 'oops'));
    await expectLater(
      _repo(adapter).latest(),
      throwsA(isA<UpdateCheckFailure>()),
    );
  });

  test('manifes rusak atau tidak aman ditolak', () async {
    for (final response in [
      textBody(200, '<html>login</html>'),
      textBody(200, '[1,2]'),
      jsonBody(200, {..._body(), 'sha256': 'pendek'}),
      jsonBody(200, _body(url: 'http://github.com/x.apk')),
    ]) {
      final adapter = FakeAdapter((r, i) => response);
      await expectLater(
        _repo(adapter).latest(),
        throwsA(isA<UpdateCheckFailure>()),
      );
    }
  });

  test('APK dari host lain daripada manifes ditolak', () async {
    final adapter = FakeAdapter(
      (r, i) => jsonBody(200, _body(url: 'https://evil.example.com/a.apk')),
    );
    await expectLater(
      _repo(adapter).latest(),
      throwsA(isA<UpdateCheckFailure>()),
    );
  });

  test(
    'pembaruan dimatikan: tidak ada rilis dan tidak ada permintaan',
    () async {
      expect(await const DisabledUpdateRepository().latest(), isNull);
    },
  );
}
