import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:employee_wellness/config/api_config.dart';
import 'package:employee_wellness/services/aktivitas_service.dart';
import 'package:employee_wellness/services/hijau_service.dart';
import 'package:employee_wellness/services/hijau_kpi_service.dart';
import 'package:employee_wellness/services/sehat_kpi_service.dart';
import 'package:employee_wellness/services/tenang_kpi_service.dart';
import 'package:employee_wellness/services/wellness_kpi_service.dart';

/// Mock backend yang mereplikasi kontrak response API
/// (`hibah-backend-admin`) untuk menguji layanan mobile secara nyata
/// melalui HTTP (mobile -> backend).
class BackendMock {
  final HttpServer server;
  final List<Map<String, dynamic>> requests = [];
  bool forceHijau400 = false;
  bool forceHijau409 = false;
  bool forceAktivitas400 = false;
  bool forceAktivitas409 = false;
  bool failWith401 = false;

  BackendMock._(this.server);

  static Future<BackendMock> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final mock = BackendMock._(server);
    server.listen((request) => mock._handle(request));
    return mock;
  }

  int get port => server.port;

  Future<void> close() => server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final body = await _readBody(request);
    final auth = request.headers.value('authorization');

    requests.add({
      'method': request.method,
      'path': request.uri.path,
      'query': request.uri.queryParameters,
      'auth': auth,
      'body': body,
    });

    final route = request.uri.path.replaceFirst('/api', '');
    var status = 200;
    Map<String, dynamic> json;

    if (request.method == 'OPTIONS') {
      request.response.statusCode = 204;
      await request.response.close();
      return;
    }

    if (request.method == 'GET') {
      json = _handleGet(route, request.uri.queryParameters);
    } else if (request.method == 'POST') {
      final (postStatus, postJson) = _handlePost(route, body);
      status = postStatus;
      json = postJson;
    } else {
      status = 405;
      json = {'success': false, 'message': 'Method not allowed'};
    }

    request.response.headers.contentType =
        ContentType('application', 'json', charset: 'utf-8');
    request.response.statusCode = status;
    request.response.write(jsonEncode(json));
    await request.response.close();
  }

  Map<String, dynamic> _handleGet(
      String route, Map<String, String> query) {
    if (failWith401) return {'success': false, 'message': 'Unauthorized'};

    if (route == '/user/hijau') {
      return {
        'success': true,
        'message': 'Data HIJAU berhasil diambil',
        'data': {
          'tanggal': '2026-08-07',
          'aktivitas': [
            {
              'id': 1,
              'tanggal': '2026-08-07',
              'aktivitas': 'hemat_listrik',
              'kategori': 'hemat_energi',
              'poin': 1,
              'deskripsi': 'Hemat Listrik',
              'carbon_saved': '0.50',
              'created_at': '2026-08-07T09:00:00',
            }
          ],
          'ringkasan': {'total_aktivitas': 1, 'total_poin': 1, 'total_carbon_saved': 0.5},
        },
      };
    }

    if (route.startsWith('/user/aktivitas')) {
      final modul = query['modul'];
      final tgl = query['tanggal'] ?? '2026-08-07';
      final isTenang = modul == 'tenang';
      return {
        'success': true,
        'message': 'Data aktivitas penilaian berhasil diambil',
        'data': {
          'tanggal': tgl,
          'modul': modul,
          'aktivitas': isTenang
              ? [
                  {'id': 11, 'modul': 'tenang', 'aktivitas': 'tahan_emosi', 'tanggal': tgl, 'poin': 1, 'created_at': '2026-08-07T09:00:00'},
                ]
              : [
                  {'id': 21, 'modul': 'sehat', 'aktivitas': 'tanpa_minyak', 'tanggal': tgl, 'poin': 1, 'created_at': '2026-08-07T09:00:00'},
                ],
          'ringkasan': {'total_aktivitas': 1, 'total_poin': 1},
        },
      };
    }

    if (route.startsWith('/user/kpi-hijau/')) {
      return {
        'success': true,
        'message': 'Data KPI HIJAU berhasil diambil',
        'data': {
          'tanggal': '2026-08-07',
          'ringkasan': {'aktivitas_selesai': 1, 'total_aktivitas': 5, 'progress_persen': 20, 'total_poin': 1},
          'aktivitas': [
            {'kode': 'hemat_air', 'nama': 'Hemat Air', 'target_harian': 1, 'selesai': false, 'poin': 0, 'bobot': '20%'},
            {'kode': 'hemat_listrik', 'nama': 'Hemat Listrik', 'target_harian': 1, 'selesai': true, 'poin': 1, 'bobot': '20%'},
            {'kode': 'gaya_hidup_hijau', 'nama': 'Gaya Hidup Hijau', 'target_harian': 1, 'selesai': false, 'poin': 0, 'bobot': '20%'},
            {'kode': 'ajak_orang_lain', 'nama': 'Ajak Orang Lain Hidup Sehat', 'target_harian': 1, 'selesai': false, 'poin': 0, 'bobot': '20%'},
            {'kode': 'ubah_kebiasaan', 'nama': 'Ubah Kebiasaan', 'target_harian': 1, 'selesai': false, 'poin': 0, 'bobot': '20%'},
          ],
          'total': {'nama': 'TOTAL', 'bobot': '100%'},
        },
      };
    }

    if (route.startsWith('/user/kpi-wellness/')) {
      return {
        'success': true,
        'message': 'Skor KPI Wellness berhasil dihitung',
        'data': {
          'periode': {'bulan': 8, 'tahun': 2026, 'nama_bulan': 'Agustus'},
          'dimensi': [
            {'modul': 'sehat', 'nama': 'SEHAT 360°', 'bobot_persen': 50, 'maks_poin_bulan': 136, 'poin_diperoleh': 122, 'persen': 89.7},
            {'modul': 'tenang', 'nama': 'TENANG 360°', 'bobot_persen': 25, 'maks_poin_bulan': 40, 'poin_diperoleh': 34, 'persen': 85},
            {'modul': 'hijau', 'nama': 'HIJAU 360°', 'bobot_persen': 25, 'maks_poin_bulan': 20, 'poin_diperoleh': 18, 'persen': 90},
          ],
          'skor_kpi_wellness': 88.6,
          'predikat': 'Baik',
          'maks_poin_bulan': 196,
          'rumus': '(%SEHAT × 50%) + (%TENANG × 25%) + (%HIJAU × 25%)',
        },
      };
    }

    if (route.startsWith('/user/kpi-sehat/')) {
      return {
        'success': true,
        'message': 'Data KPI SEHAT berhasil diambil',
        'data': {
          'tanggal': '2026-08-07',
          'ringkasan': {'total_poin': 80, 'progress_persen': 60},
          'aktivitas': [],
        },
      };
    }

    if (route.startsWith('/user/kpi-tenang/')) {
      return {
        'success': true,
        'message': 'Data KPI TENANG berhasil diambil',
        'data': {
          'tanggal': '2026-08-07',
          'ringkasan': {'total_poin': 40, 'progress_persen': 55},
          'aktivitas': [],
        },
      };
    }

    return {'success': false, 'message': 'Not found'};
  }

  (int, Map<String, dynamic>) _handlePost(
      String route, Map<String, dynamic>? body) {
    if (route == '/user/hijau') {
      if (forceHijau409) {
        return (
          409,
          {
            'success': false,
            'message':
                'Aktivitas hemat_listrik sudah dicapai minggu ini (maksimal 1 poin/minggu).',
            'data': {'aktivitas': 'hemat_listrik', 'cap_tercapai': true, 'pekan': 2},
          }
        );
      }
      if (forceHijau400) {
        return (
          400,
          {'success': false, 'message': 'Parameter "aktivitas" diperlukan'}
        );
      }
      return (
        201,
        {
          'success': true,
          'message': 'Aktivitas HIJAU berhasil dicatat',
          'data': {
            'id': 1,
            'aktivitas': body?['activity_type'],
            'kategori': body?['kategori'],
            'poin': body?['points'] ?? 1,
          },
        }
      );
    }

    if (route == '/user/aktivitas') {
      if (forceAktivitas409) {
        return (
          409,
          {
            'success': false,
            'message':
                'Aktivitas "tanpa_minyak" sudah mencapai batas 2 poin/minggu pada pekan ke-1.',
            'data': {'modul': body?['modul'], 'aktivitas': body?['aktivitas'], 'cap_tercapai': true, 'cap': 2, 'pekan': 1},
          }
        );
      }
      if (forceAktivitas400) {
        return (
          400,
          {'success': false, 'message': 'Aktivitas tidak dikenali untuk modul sehat.'}
        );
      }
      return (
        201,
        {
          'success': true,
          'message': 'Aktivitas penilaian berhasil dicatat (+1 poin)',
          'data': {
            'id': 2,
            'modul': body?['modul'],
            'aktivitas': body?['aktivitas'],
            'tanggal': '2026-08-07',
            'poin': 1,
          },
        }
      );
    }

    if (route == '/user/langkah') {
      return (200, {'success': true, 'message': 'Langkah berhasil disimpan'});
    }

    return (404, {'success': false, 'message': 'Not found'});
  }

  static Future<Map<String, dynamic>?> _readBody(HttpRequest request) async {
    if (request.method == 'GET') return null;
    final content = await utf8.decoder.bind(request).join();
    if (content.isEmpty) return null;
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

void main() {
  late BackendMock backend;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'test-token-12345-abcdefghij',
      'token': 'test-token-12345-abcdefghij',
    });
    backend = await BackendMock.start();
    ApiConfig.baseUrl = 'http://localhost:${backend.port}/api';
  });

  tearDown(() async {
    await backend.close();
  });

  group('HIJAU mobile -> backend', () {
    test('recordGreenActivity: POST /user/hijau, body cocok kontrak', () async {
      final result = await HijauService.recordGreenActivity(
        activityType: 'hemat_listrik',
        description: 'Hemat Listrik',
        points: 1,
        category: 'hemat_energi',
        carbonSaved: 0.5,
      );

      expect(result['success'], isTrue);
      final responseBody = result['data'] as Map<String, dynamic>;
      expect(responseBody['data']['id'], 1);
      expect(responseBody['data']['aktivitas'], 'hemat_listrik');
      expect(responseBody['data']['kategori'], 'hemat_energi');
      expect(responseBody['data']['poin'], 1);

      final req = backend.requests.last;
      expect(req['method'], 'POST');
      expect(req['path'], '/api/user/hijau');
      expect(req['auth'], 'Bearer test-token-12345-abcdefghij');

      final body = req['body'] as Map<String, dynamic>;
      expect(body['activity_type'], 'hemat_listrik');
      expect(body['description'], 'Hemat Listrik');
      expect(body['kategori'], 'hemat_energi');
      expect(body['points'], 1);
      expect(body['carbon_saved'], 0.5);
      expect(body.containsKey('date'), isTrue);
    });

    test('recordGreenActivity: body hanya wajib activity_type + description', () async {
      final result = await HijauService.recordGreenActivity(
        activityType: 'gaya_hidup_hijau',
        description: 'Menerapkan gaya hidup hijau',
      );
      expect(result['success'], isTrue);
      final body = backend.requests.last['body'] as Map<String, dynamic>;
      expect(body['activity_type'], 'gaya_hidup_hijau');
      expect(body.containsKey('kategori'), isFalse);
      expect(body.containsKey('points'), isFalse);
    });

    test('recordGreenActivity: backend 400 (missing aktivitas) -> success=false', () async {
      backend.forceHijau400 = true;
      final result = await HijauService.recordGreenActivity(
        activityType: '',
        description: 'x',
      );
      expect(result['success'], isFalse);
    });

    test('recordGreenActivity: cap mingguan backend 409 -> success=false + statusCode', () async {
      backend.forceHijau409 = true;
      final result = await HijauService.recordGreenActivity(
        activityType: 'hemat_listrik',
        description: 'Hemat Listrik',
        points: 1,
      );
      expect(result['success'], isFalse);
      expect(result['statusCode'], 409);
      expect(
        result['message'].toString().contains('maksimal 1 poin/minggu'),
        isTrue,
      );
    });

    test('getHijauData: GET /user/hijau, parse ringkasan dari backend', () async {
      final result = await HijauService.getHijauData();
      expect(result['success'], isTrue);
      final data = (result['data'] as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      expect(data['tanggal'], '2026-08-07');
      final ringkasan = data['ringkasan'] as Map<String, dynamic>;
      expect(ringkasan['total_poin'], 1);
      expect(data['aktivitas'], isA<List<dynamic>>());
    });

    test('getCarbonFootprint: GET /user/hijau tanpa query params', () async {
      final result = await HijauService.getCarbonFootprint();
      expect(result['success'], isTrue);
      expect(backend.requests.last['path'], '/api/user/hijau');
    });

    test('getWeeklyKPI: GET /user/kpi-hijau/mingguan -> 5 aktivitas HIJAU 360°', () async {
      final result = await HijauKPIService.getWeeklyKPI();
      expect(result['success'], isTrue);
      final aktivitas = (result['data'] as Map<String, dynamic>)['aktivitas']
          as List<dynamic>;
      expect(aktivitas.length, 5);
      final kodes = aktivitas
          .map((a) => a['kode'])
          .toSet();
      expect(kodes, containsAll(['hemat_air', 'hemat_listrik', 'gaya_hidup_hijau', 'ajak_orang_lain', 'ubah_kebiasaan']));
      final ringkasan = (result['data'] as Map<String, dynamic>)['ringkasan'];
      expect(ringkasan['total_aktivitas'], 5);
    });
  });

  group('SEHAT mobile -> backend', () {
    test('updateStepsWithDate: POST /user/langkah, body cocok kontrak', () async {
      final result = await SehatKPIService.updateStepsWithDate(
        tanggal: '2026-08-07',
        totalSteps: 8000,
      );
      expect(result['success'], isTrue);

      final req = backend.requests.last;
      expect(req['method'], 'POST');
      expect(req['path'], '/api/user/langkah');
      expect(req['auth'], 'Bearer test-token-12345-abcdefghij');

      final body = req['body'] as Map<String, dynamic>;
      expect(body['jumlah_langkah'], 8000);
      expect(body['tanggal'], '2026-08-07');
    });

    test('getDailyKPI: GET /user/kpi-sehat/harian?tanggal=...', () async {
      final result = await SehatKPIService.getDailyKPI(tanggal: '2026-08-07');
      expect(result['success'], isTrue);
      final req = backend.requests.last;
      expect(req['method'], 'GET');
      expect(req['path'], '/api/user/kpi-sehat/harian');
      expect(req['query'], {'tanggal': '2026-08-07'});
      expect((result['data'] as Map)['ringkasan'], isNotNull);
    });

    test('getWeeklyKPI: GET /user/kpi-sehat/mingguan?minggu_ke&bulan&tahun', () async {
      final result = await SehatKPIService.getWeeklyKPI(
        mingguKe: 2, bulan: 8, tahun: 2026,
      );
      expect(result['success'], isTrue);
      final req = backend.requests.last;
      expect(req['path'], '/api/user/kpi-sehat/mingguan');
      expect(req['query'],
          {'minggu_ke': '2', 'bulan': '8', 'tahun': '2026'});
    });

    test('getMonthlyKPI: GET /user/kpi-sehat/bulanan?bulan&tahun', () async {
      final result = await SehatKPIService.getMonthlyKPI(bulan: 8, tahun: 2026);
      expect(result['success'], isTrue);
      final req = backend.requests.last;
      expect(req['path'], '/api/user/kpi-sehat/bulanan');
      expect(req['query'], {'bulan': '8', 'tahun': '2026'});
    });

    test('401 dari backend ditangani graceful (tidak crash)', () async {
      backend.failWith401 = true;
      final result = await SehatKPIService.getDailyKPI();
      expect(result['success'], isFalse);
    });
  });

  group('TENANG mobile -> backend', () {
    test('getDailyKPI: GET /user/kpi-tenang/harian', () async {
      final result = await TenangKPIService.getDailyKPI(tanggal: '2026-08-07');
      expect(result['success'], isTrue);
      final req = backend.requests.last;
      expect(req['method'], 'GET');
      expect(req['path'], '/api/user/kpi-tenang/harian');
      expect(req['query'], {'tanggal': '2026-08-07'});
    });

    test('getWeeklyKPI: GET /user/kpi-tenang/mingguan?minggu_ke', () async {
      final result = await TenangKPIService.getWeeklyKPI(mingguKe: 1);
      expect(result['success'], isTrue);
      final req = backend.requests.last;
      expect(req['path'], '/api/user/kpi-tenang/mingguan');
      expect(req['query'], {'minggu_ke': '1'});
    });

    test('getMonthlyKPI: GET /user/kpi-tenang/bulanan?bulan&tahun', () async {
      final result = await TenangKPIService.getMonthlyKPI(bulan: 8, tahun: 2026);
      expect(result['success'], isTrue);
      final req = backend.requests.last;
      expect(req['path'], '/api/user/kpi-tenang/bulanan');
      expect(req['query'], {'bulan': '8', 'tahun': '2026'});
    });
  });

  group('PENILAIAN mobile -> backend', () {
    test('recordAktivitas SEHAT: POST /user/aktivitas, body cocok kontrak', () async {
      final result = await AktivitasService.recordAktivitas(
        modul: 'sehat',
        aktivitas: 'tanpa_minyak',
        deskripsi: 'Makan Tanpa Minyak',
      );

      expect(result['success'], isTrue);
      final responseBody = result['data'] as Map<String, dynamic>;
      expect(responseBody['id'], 2);
      expect(responseBody['modul'], 'sehat');
      expect(responseBody['aktivitas'], 'tanpa_minyak');
      expect(responseBody['poin'], 1);

      final req = backend.requests.last;
      expect(req['method'], 'POST');
      expect(req['path'], '/api/user/aktivitas');
      expect(req['auth'], 'Bearer test-token-12345-abcdefghij');

      final body = req['body'] as Map<String, dynamic>;
      expect(body['modul'], 'sehat');
      expect(body['aktivitas'], 'tanpa_minyak');
      expect(body['deskripsi'], 'Makan Tanpa Minyak');
    });

    test('recordAktivitas TENANG: body hanya wajib modul + aktivitas', () async {
      final result = await AktivitasService.recordAktivitas(
        modul: 'tenang',
        aktivitas: 'tahan_emosi',
      );
      expect(result['success'], isTrue);
      final body = backend.requests.last['body'] as Map<String, dynamic>;
      expect(body['modul'], 'tenang');
      expect(body['aktivitas'], 'tahan_emosi');
      expect(body.containsKey('tanggal'), isFalse);
      expect(body.containsKey('deskripsi'), isFalse);
    });

    test('recordAktivitas: cap mingguan backend 409 -> success=false + statusCode', () async {
      backend.forceAktivitas409 = true;
      final result = await AktivitasService.recordAktivitas(
        modul: 'sehat',
        aktivitas: 'tanpa_minyak',
      );
      expect(result['success'], isFalse);
      expect(result['statusCode'], 409);
      expect(
        result['message'].toString().contains('batas 2 poin/minggu'),
        isTrue,
      );
    });

    test('recordAktivitas: aktivitas tak dikenali 400 -> success=false', () async {
      backend.forceAktivitas400 = true;
      final result = await AktivitasService.recordAktivitas(
        modul: 'sehat',
        aktivitas: 'bukan_aktivitas',
      );
      expect(result['success'], isFalse);
      expect(result['statusCode'], 400);
    });

    test('getAktivitas: GET /user/aktivitas?modul=tenang&tanggal=...', () async {
      final result = await AktivitasService.getAktivitas(
        modul: 'tenang',
        tanggal: '2026-08-07',
      );
      expect(result['success'], isTrue);
      final req = backend.requests.last;
      expect(req['method'], 'GET');
      expect(req['path'], '/api/user/aktivitas');
      expect(req['query'], {'modul': 'tenang', 'tanggal': '2026-08-07'});

      final data = result['data'] as Map<String, dynamic>;
      final aktivitas = data['aktivitas'] as List<dynamic>;
      expect(aktivitas.first['aktivitas'], 'tahan_emosi');
      expect((data['ringkasan'] as Map<String, dynamic>)['total_poin'], 1);
    });
  });

  group('WELLNESS mobile -> backend', () {
    test('getMonthlyWellness: GET /user/kpi-wellness/bulanan, parse skor + predikat', () async {
      final result = await WellnessKPIService.getMonthlyWellness(bulan: 8, tahun: 2026);
      expect(result['success'], isTrue);
      final req = backend.requests.last;
      expect(req['method'], 'GET');
      expect(req['path'], '/api/user/kpi-wellness/bulanan');
      expect(req['query'], {'bulan': '8', 'tahun': '2026'});

      final data = result['data'] as Map<String, dynamic>;
      expect(data['skor_kpi_wellness'], 88.6);
      expect(data['predikat'], 'Baik');
      final dimensi = data['dimensi'] as List<dynamic>;
      expect(dimensi.length, 3);
      expect(dimensi[0]['modul'], 'sehat');
      expect(data['maks_poin_bulan'], 196);
    });

    test('skor wellness sesuai rumus (89,7×0,5)+(85×0,25)+(90×0,25)=88,6', () {
      final skor = (89.7 * 0.5) + (85 * 0.25) + (90 * 0.25);
      expect(skor, closeTo(88.6, 0.05));
    });
  });
}
