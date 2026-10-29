import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Titik scan HIJAU 360  satu klik = satu laporan = 1 poin,
/// dibatasi cap mingguan per aktivitas (maks 1 poin/minggu per aktivitas).
class HijauScanPoint {
  /// Kode KPI kanonik backend (hemat_air, hemat_listrik, ...).
  final String kode;

  /// Sub-modul di aplikasi (hemat_energi, zero_waste, ...).
  final String kategori;

  final String title;
  final String emoji;
  final FaIconData icon;
  final Color color;
  final Color softColor;

  /// Teks wawasan singkat setelah menonton video.
  final String insight;

  /// Label tombol konfirmasi, mis. "Sudah Hemat Air".
  final String confirmLabel;

  /// Aset video animasi (bisa null bila tidak ada).
  final String? videoAsset;

  /// Animasi transparan untuk ditampilkan sebagai objek AR di atas kamera.
  final String? arOverlayAsset;

  /// Target poin per minggu (cap).
  final int targetPerWeek;

  /// Target poin per bulan.
  final int targetPerMonth;

  /// Label ML Kit yang dianggap valid untuk kategori ini (case-insensitive, substring match).
  /// Digunakan di `hijau_scan_page.dart` untuk matching objek terdeteksi → kode aktivitas.
  final List<String> arLabels;

  const HijauScanPoint({
    required this.kode,
    required this.kategori,
    required this.title,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.insight,
    required this.confirmLabel,
    this.videoAsset,
    this.arOverlayAsset,
    this.targetPerWeek = 1,
    this.targetPerMonth = 4,
    this.arLabels = const [],
  });
}

/// Titik scan per halaman. Zero Waste berbagi kode dengan Gaya Hidup Hijau
/// (sama-sama 'gaya_hidup_hijau') sehingga cap mingguannya menyatu.
class HijauScanPoints {
  static const hematAir = HijauScanPoint(
    kode: 'hemat_air',
    kategori: 'konservasi_air',
    title: 'Hemat Air',
    emoji: '',
    icon: FontAwesomeIcons.faucetDrip,
    color: Color(0xff0ea5e9),
    softColor: Color(0xfff0f9ff),
    insight:
        'Menutup keran rapat dan memperbaiki kebocoran bisa menghemat puluhan '
        'liter air per hari. Air bersih adalah sumber daya terbatas  hemat hari '
        'ini berarti masa depan yang lebih berkelanjutan.',
    confirmLabel: 'Sudah Hemat Air',
    videoAsset: 'assets/videos/keranAir.mp4',
    arOverlayAsset: 'assets/videos/keranAir-vr.webp',
    targetPerWeek: 1,
    targetPerMonth: 4,
    arLabels: [
      'faucet',
      'tap',
      'sink',
      'bucket',
      'pale',
      'ember',
      'gayung',
      'shower',
      'water',
    ],
  );

  static const hematListrik = HijauScanPoint(
    kode: 'hemat_listrik',
    kategori: 'hemat_energi',
    title: 'Hemat Listrik',
    emoji: '',
    icon: FontAwesomeIcons.bolt,
    color: Color(0xff059669),
    softColor: Color(0xffecfdf5),
    insight:
        'Mematikan lampu dan AC saat ruangan kosong memangkas konsumsi listrik '
        'kantor. Selain menekan tagihan, langkah ini mengurangi emisi karbon '
        'dari pembangkit listrik.',
    confirmLabel: 'Sudah Hemat Listrik',
    videoAsset: 'assets/videos/listrik.mp4',
    targetPerWeek: 1,
    targetPerMonth: 4,
    // Diperluas: ML Kit sering label "Light fixture", "Ceiling", "Wall", "Electricity",
    // "Cord/Wire" — bukan hanya "switch/outlet". Tambah sinonim Indonesia juga.
    arLabels: [
      'light',
      'lamp',
      'light bulb',
      'light fixture',
      'ceiling light',
      'lamp shade',
      'light switch',
      'switch',
      'saklar',
      'outlet',
      'electrical outlet',
      'power outlet',
      'wall socket',
      'socket',
      'plug',
      'power plug',
      'steker',
      'colokan',
      'stopkontak',
      'stop kontak',
      'terminal',
      'power strip',
      'extension cord',
      'cord',
      'wire',
      'cable',
      'kabel',
      'electric',
      'electricity',
      'electronic',
      'power',
      'charger',
      'adapter',
      'lampu',
      'listrik',
    ],
  );

  static const gayaHidupHijau = HijauScanPoint(
    kode: 'gaya_hidup_hijau',
    kategori: 'gaya_hidup_hijau',
    title: 'Gaya Hidup Hijau',
    emoji: '',
    icon: FontAwesomeIcons.leaf,
    color: Color(0xff16a34a),
    softColor: Color(0xfff7fee7),
    insight:
        'Tak harus serentak  pilih satu kebiasaan hijau dan lakukan secara '
        'konsisten. Perubahan kecil yang bertahan lebih berdampak daripada '
        'perubahan besar yang berhenti di tengah jalan.',
    confirmLabel: 'Sudah Melakukan',
    targetPerWeek: 1,
    targetPerMonth: 4,
    arLabels: [
      'bottle',
      'tumbler',
      'cup',
      'mug',
      'bag',
      'tas',
      'tote',
      'bicycle',
      'bike',
      'sepeda',
      'recycling',
      'cloth',
    ],
  );

  static const zeroWaste = HijauScanPoint(
    kode: 'gaya_hidup_hijau',
    kategori: 'zero_waste',
    title: 'Zero Waste',
    emoji: '',
    icon: FontAwesomeIcons.recycle,
    color: Color(0xff16a34a),
    softColor: Color(0xfff0fdf4),
    insight:
        'Kurangi sampah sekali pakai: bawa tumbler, tas belanja, dan wadah '
        'makan sendiri. Setiap benda yang tidak terbuang berarti satu langkah '
        'menjaga lingkungan.',
    confirmLabel: 'Sudah Melakukan',
    videoAsset: 'assets/videos/tempat-sampah.mp4',
    arOverlayAsset: 'assets/videos/tempat-sampah-vr.webp',
    targetPerWeek: 1,
    targetPerMonth: 4,
  );

  static const ajakOrangLain = HijauScanPoint(
    kode: 'ajak_orang_lain',
    kategori: 'ajak_orang_lain',
    title: 'Ajak Orang Lain',
    emoji: '',
    icon: FontAwesomeIcons.userPlus,
    color: Color(0xfff59e0b),
    softColor: Color(0xfffffbeb),
    insight:
        'Ajak rekan kerja ikut menerapkan kebiasaan hijau. Kebiasaan sehat '
        'lebih mudah bertahan bila dilakukan bersama dan jadi gerakan yang '
        'menyenangkan, bukan paksaan.',
    confirmLabel: 'Sudah Mengajak',
    targetPerWeek: 1,
    targetPerMonth: 4,
    // AR: aksi sosial — gunakan face detection ≥2 wajah sebagai sinyal pendukung (tidak full-auto)
    arLabels: ['person', 'people', 'face', 'group'],
  );

  static const ubahKebiasaan = HijauScanPoint(
    kode: 'ubah_kebiasaan',
    kategori: 'ubah_kebiasaan',
    title: 'Ubah Kebiasaan',
    emoji: '',
    icon: FontAwesomeIcons.arrowsRotate,
    color: Color(0xff10b981),
    softColor: Color(0xffecfdf5),
    insight:
        'Rata-rata dibutuhkan 2166 hari agar sebuah tindakan menjadi kebiasaan '
        'otomatis. Pilih satu kebiasaan hijau dan ulangi setiap hari sampai '
        'menjadi refleks.',
    confirmLabel: 'Sudah Jadi Kebiasaan',
    videoAsset: 'assets/videos/tempat-sampah.mp4',
    arOverlayAsset: 'assets/videos/tempat-sampah-vr.webp',
    targetPerWeek: 1,
    targetPerMonth: 4,
    arLabels: [
      'trash can',
      'bin',
      'recycling bin',
      'sampah',
      'pilah',
      'stairs',
      'staircase',
      'tangga',
      'litter',
    ],
  );

  /// Semua titik penilaian HIJAU (5 aktivitas unik backend).
  static const semua = <HijauScanPoint>[
    hematAir,
    hematListrik,
    gayaHidupHijau,
    ajakOrangLain,
    ubahKebiasaan,
  ];

  /// Maksimal poin per minggu (5 aktivitas  1 = 5).
  static const int maksPerMinggu = 5;

  /// Maksimal poin per bulan (5 aktivitas  4 = 20).
  static const int maksPerBulan = 20;

  /// Helper: cek apakah label ML Kit cocok untuk kode tertentu (case-insensitive, substring).
  static bool isLabelMatch(String label, String kode) {
    final q = label.toLowerCase();
    final point = semua.firstWhere(
      (p) => p.kode == kode,
      orElse: () => semua.first,
    );
    if (point.kode != kode) return false;
    if (point.arLabels.isEmpty) return false;
    return point.arLabels.any((kw) => q.contains(kw.toLowerCase()));
  }

  /// Threshold awal: 0.55 terbukti lebih robust untuk objek kecil (saklar/colokan)
  /// tanpa banyak false positive. Tetap disaring per-kata kunci, bukan global.
  static const double confidenceThreshold = 0.55;
  static const int requiredConsecutiveFrames = 2;

  /// Timeout auto-fallback ke manual jika tidak terdeteksi dalam durasi ini.
  static const Duration scanTimeout = Duration(seconds: 30);
}
