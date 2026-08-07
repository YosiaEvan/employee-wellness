import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:employee_wellness/services/langkah_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LangkahService offline queue', () {
    test('saveDailyRecordToQueue menambahkan record baru', () async {
      await LangkahService.saveDailyRecordToQueue(
        tanggal: '2026-08-07',
        jumlahLangkah: 8000,
      );
      final queue = await LangkahService.getPendingQueue();
      expect(queue.length, 1);
      expect(queue.first['tanggal'], '2026-08-07');
      expect(queue.first['jumlah_langkah'], 8000);
    });

    test('saveDailyRecordToQueue mengupdate record dengan tanggal yang sama', () async {
      await LangkahService.saveDailyRecordToQueue(tanggal: '2026-08-07', jumlahLangkah: 5000);
      await LangkahService.saveDailyRecordToQueue(tanggal: '2026-08-07', jumlahLangkah: 9000);

      final queue = await LangkahService.getPendingQueue();
      expect(queue.length, 1);
      expect(queue.first['jumlah_langkah'], 9000);
    });

    test('removeFromQueue menghapus record sesuai tanggal', () async {
      await LangkahService.saveDailyRecordToQueue(tanggal: '2026-08-07', jumlahLangkah: 8000);
      await LangkahService.saveDailyRecordToQueue(tanggal: '2026-08-06', jumlahLangkah: 7000);

      await LangkahService.removeFromQueue('2026-08-07');
      final queue = await LangkahService.getPendingQueue();
      expect(queue.length, 1);
      expect(queue.first['tanggal'], '2026-08-06');
    });

    test('clearQueue menghapus seluruh antrian', () async {
      await LangkahService.saveDailyRecordToQueue(tanggal: '2026-08-07', jumlahLangkah: 8000);
      await LangkahService.clearQueue();
      expect(await LangkahService.getPendingQueue(), isEmpty);
    });

    test('shouldResetToday true saat belum ada last_sync_date', () async {
      expect(await LangkahService.shouldResetToday(), isTrue);
    });

    test('shouldResetToday false saat tanggal masih sama', () async {
      await LangkahService.saveLastSyncDate();
      expect(await LangkahService.shouldResetToday(), isFalse);
    });

    test('saveTodaySteps/getTodaySteps roundtrip', () async {
      await LangkahService.saveTodaySteps(1234);
      expect(await LangkahService.getTodaySteps(), 1234);
    });
  });
}
