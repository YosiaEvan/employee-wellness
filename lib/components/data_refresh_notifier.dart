import 'package:flutter/foundation.dart';

/// Global event bus untuk memberi tahu seluruh widget bahwa data
/// (aktivitas/KPI) telah berubah di backend/lokal, sehingga widget dapat
/// me-refresh datanya segera tanpa menunggu timer berkala.
///
/// Setiap service pemanggil data memanggil [notifyDataChanged] setelah
/// berhasil menyimpan/post. Widget penampil KPI (kartu modul, dashboard,
/// wellness, dll.) memanggil [addListener] untuk reload saat ada perubahan.
class DataRefreshNotifier extends ChangeNotifier {
  DataRefreshNotifier._();

  static final DataRefreshNotifier instance = DataRefreshNotifier._();

  /// Beri sinyal bahwa ada data baru/berubah.
  void notifyDataChanged() {
    notifyListeners();
  }
}
