import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Titik scan HIJAU 360° — satu klik = satu laporan = 1 poin,
/// maksimal 1 poin/minggu per aktivitas (4/bulan).
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
  });
}

/// Titik scan per halaman. Zero Waste berbagi kode dengan Gaya Hidup Hijau
/// (sama-sama 'gaya_hidup_hijau') sehingga cap mingguannya menyatu.
class HijauScanPoints {
  static const hematAir = HijauScanPoint(
    kode: 'hemat_air',
    kategori: 'konservasi_air',
    title: 'Hemat Air',
    emoji: '💧',
    icon: FontAwesomeIcons.faucetDrip,
    color: Color(0xff0ea5e9),
    softColor: Color(0xfff0f9ff),
    insight:
        'Menutup keran rapat dan memperbaiki kebocoran bisa menghemat puluhan '
        'liter air per hari. Air bersih adalah sumber daya terbatas — hemat hari '
        'ini berarti masa depan yang lebih berkelanjutan.',
    confirmLabel: 'Sudah Hemat Air',
    videoAsset: 'assets/videos/keran.mp4',
  );

  static const hematListrik = HijauScanPoint(
    kode: 'hemat_listrik',
    kategori: 'hemat_energi',
    title: 'Hemat Listrik',
    emoji: '⚡',
    icon: FontAwesomeIcons.bolt,
    color: Color(0xff059669),
    softColor: Color(0xffecfdf5),
    insight:
        'Mematikan lampu dan AC saat ruangan kosong memangkas konsumsi listrik '
        'kantor. Selain menekan tagihan, langkah ini mengurangi emisi karbon '
        'dari pembangkit listrik.',
    confirmLabel: 'Sudah Hemat Listrik',
    videoAsset: 'assets/videos/listrik.mp4',
  );

  static const gayaHidupHijau = HijauScanPoint(
    kode: 'gaya_hidup_hijau',
    kategori: 'gaya_hidup_hijau',
    title: 'Gaya Hidup Hijau',
    emoji: '🌿',
    icon: FontAwesomeIcons.leaf,
    color: Color(0xff16a34a),
    softColor: Color(0xfff7fee7),
    insight:
        'Tak harus serentak — pilih satu kebiasaan hijau dan lakukan secara '
        'konsisten. Perubahan kecil yang bertahan lebih berdampak daripada '
        'perubahan besar yang berhenti di tengah jalan.',
    confirmLabel: 'Sudah Melakukan',
  );

  static const zeroWaste = HijauScanPoint(
    kode: 'gaya_hidup_hijau',
    kategori: 'zero_waste',
    title: 'Zero Waste',
    emoji: '♻️',
    icon: FontAwesomeIcons.recycle,
    color: Color(0xff16a34a),
    softColor: Color(0xfff0fdf4),
    insight:
        'Kurangi sampah sekali pakai: bawa tumbler, tas belanja, dan wadah '
        'makan sendiri. Setiap benda yang tidak terbuang berarti satu langkah '
        'menjaga lingkungan.',
    confirmLabel: 'Sudah Melakukan',
  );

  static const ajakOrangLain = HijauScanPoint(
    kode: 'ajak_orang_lain',
    kategori: 'ajak_orang_lain',
    title: 'Ajak Orang Lain',
    emoji: '🤝',
    icon: FontAwesomeIcons.userPlus,
    color: Color(0xfff59e0b),
    softColor: Color(0xfffffbeb),
    insight:
        'Ajak rekan kerja ikut menerapkan kebiasaan hijau. Kebiasaan sehat '
        'lebih mudah bertahan bila dilakukan bersama dan jadi gerakan yang '
        'menyenangkan, bukan paksaan.',
    confirmLabel: 'Sudah Mengajak',
  );

  static const ubahKebiasaan = HijauScanPoint(
    kode: 'ubah_kebiasaan',
    kategori: 'ubah_kebiasaan',
    title: 'Ubah Kebiasaan',
    emoji: '🔄',
    icon: FontAwesomeIcons.arrowsRotate,
    color: Color(0xff10b981),
    softColor: Color(0xffecfdf5),
    insight:
        'Rata-rata dibutuhkan 21–66 hari agar sebuah tindakan menjadi kebiasaan '
        'otomatis. Pilih satu kebiasaan hijau dan ulangi setiap hari sampai '
        'menjadi refleks.',
    confirmLabel: 'Sudah Jadi Kebiasaan',
  );
}
