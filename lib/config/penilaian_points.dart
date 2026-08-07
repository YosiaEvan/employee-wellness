import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Titik klik penilaian SEHAT 360° / TENANG 360°.
/// Satu klik self-report = satu laporan = 1 poin,
/// dibatasi cap mingguan per aktivitas (sesuai `penilaian.md`).
class PenilaianPoint {
  /// Modul KPI: 'sehat' | 'tenang'.
  final String modul;

  /// Kode aktivitas kanonik backend (tanpa_minyak, tahan_emosi, ...).
  final String kode;

  final String title;
  final String emoji;
  final FaIconData icon;
  final Color color;
  final Color softColor;

  /// Penjelasan singkat yang ditampilkan di halaman klik.
  final String description;

  /// Label tombol konfirmasi, mis. "Makan Tanpa Minyak".
  final String confirmLabel;

  /// Target poin per minggu (cap) dari `penilaian.md`.
  final int targetPerWeek;

  /// Target poin per bulan.
  final int targetPerMonth;

  const PenilaianPoint({
    required this.modul,
    required this.kode,
    required this.title,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.description,
    required this.confirmLabel,
    required this.targetPerWeek,
    required this.targetPerMonth,
  });
}

/// SEHAT 360° — maksimal 34 poin/minggu, 136 poin/bulan.
class SehatPenilaianPoints {
  static const berjemur = PenilaianPoint(
    modul: 'sehat',
    kode: 'berjemur',
    title: 'Berjemur Matahari',
    emoji: '☀️',
    icon: FontAwesomeIcons.cloudSun,
    color: Color(0xfffb8f00),
    softColor: Color(0xfffff7ed),
    description: 'Paparan matahari pagi/sore (07.00-09.00 atau 15.00-17.00) '
        'membantu tubuh memproduksi vitamin D.',
    confirmLabel: 'Sudah Berjemur',
    targetPerWeek: 1,
    targetPerMonth: 4,
  );

  static const langkah10000 = PenilaianPoint(
    modul: 'sehat',
    kode: 'langkah_10000',
    title: 'Olahraga 10.000 Langkah',
    emoji: '🚶',
    icon: FontAwesomeIcons.shoePrints,
    color: Color(0xff1b8cfd),
    softColor: Color(0xffecfeff),
    description: 'Aktivitas fisik 10.000 langkah/hari menjaga kebugaran '
        'jantung dan metabolisme tubuh.',
    confirmLabel: 'Sudah 10.000 Langkah',
    targetPerWeek: 5,
    targetPerMonth: 20,
  );

  static const tanpaMinyak = PenilaianPoint(
    modul: 'sehat',
    kode: 'tanpa_minyak',
    title: 'Makan Tanpa Minyak',
    emoji: '🥗',
    icon: FontAwesomeIcons.bowlRice,
    color: Color(0xff00c368),
    softColor: Color(0xffeefdf5),
    description: 'Memilih makanan rebus/kukus/panggang mengurangi asupan '
        'lemak jenuh dan kalori harian.',
    confirmLabel: 'Sudah Makan Tanpa Minyak',
    targetPerWeek: 2,
    targetPerMonth: 8,
  );

  static const tanpaGula = PenilaianPoint(
    modul: 'sehat',
    kode: 'tanpa_gula',
    title: 'Tanpa Gula',
    emoji: '🍚',
    icon: FontAwesomeIcons.cookie,
    color: Color(0xff00a896),
    softColor: Color(0xffe6faf7),
    description: 'Menghindari gula tambahan menjaga gula darah stabil '
        'dan mengurangi risiko diabetes.',
    confirmLabel: 'Sudah Tanpa Gula',
    targetPerWeek: 2,
    targetPerMonth: 8,
  );

  static const porsiKalori = PenilaianPoint(
    modul: 'sehat',
    kode: 'porsi_kalori',
    title: 'Makan Sesuai Porsi Kalori Ideal',
    emoji: '⚖️',
    icon: FontAwesomeIcons.scaleBalanced,
    color: Color(0xfff59e0b),
    softColor: Color(0xfffff8e1),
    description: 'Menyesuaikan porsi makan dengan target kalori harian '
        'membantu menjaga berat badan ideal.',
    confirmLabel: 'Sudah Sesuai Porsi Kalori',
    targetPerWeek: 5,
    targetPerMonth: 20,
  );

  static const napas448 = PenilaianPoint(
    modul: 'sehat',
    kode: 'napas_448',
    title: 'Hirup Udara Segar (Napas 4-4-8)',
    emoji: '🌬️',
    icon: FontAwesomeIcons.wind,
    color: Color(0xff009bf4),
    softColor: Color(0xffeefaff),
    description: 'Teknik napas 4-4-8 (tarik-tahan-hembus) menenangkan '
        'sistem saraf dan meningkatkan fokus.',
    confirmLabel: 'Sudah Napas 4-4-8',
    targetPerWeek: 5,
    targetPerMonth: 20,
  );

  static const minum8Gelas = PenilaianPoint(
    modul: 'sehat',
    kode: 'minum_8_gelas',
    title: 'Minum 8 Gelas Air',
    emoji: '💧',
    icon: FontAwesomeIcons.glassWater,
    color: Color(0xff00cbf6),
    softColor: Color(0xffedfaff),
    description: 'Minum 8 gelas air/hari menjaga hidrasi dan fungsi '
        'organ tubuh tetap optimal.',
    confirmLabel: 'Sudah Minum 8 Gelas',
    targetPerWeek: 7,
    targetPerMonth: 28,
  );

  static const tidur78 = PenilaianPoint(
    modul: 'sehat',
    kode: 'tidur_78',
    title: 'Tidur 7-8 Jam',
    emoji: '😴',
    icon: FontAwesomeIcons.moon,
    color: Color(0xff715cff),
    softColor: Color(0xfff4f4ff),
    description: 'Tidur 7-8 jam (mulai maksimal 21.00) memulihkan tubuh '
        'dan menjaga kesehatan mental.',
    confirmLabel: 'Sudah Tidur 7-8 Jam',
    targetPerWeek: 7,
    targetPerMonth: 28,
  );

  static const semua = <PenilaianPoint>[
    berjemur,
    langkah10000,
    tanpaMinyak,
    tanpaGula,
    porsiKalori,
    napas448,
    minum8Gelas,
    tidur78,
  ];
}

/// TENANG 360° — maksimal 10 poin/minggu, 40 poin/bulan.
class TenangPenilaianPoints {
  static const tahanEmosi = PenilaianPoint(
    modul: 'tenang',
    kode: 'tahan_emosi',
    title: 'Tahan Emosi (Napas 4-4-8)',
    emoji: '🫁',
    icon: FontAwesomeIcons.handHoldingHeart,
    color: Color(0xff7141fc),
    softColor: Color(0xfff0ecff),
    description: 'Saat emosi muncul, tahan dengan teknik napas 4-4-8 '
        'sebelum bereaksi.',
    confirmLabel: 'Sudah Tahan Emosi',
    targetPerWeek: 1,
    targetPerMonth: 4,
  );

  static const ekspresiSehat = PenilaianPoint(
    modul: 'tenang',
    kode: 'ekspresi_sehat',
    title: 'Ekspresikan Sehat (Me-Time)',
    emoji: '🎧',
    icon: FontAwesomeIcons.music,
    color: Color(0xfff20868),
    softColor: Color(0xffffecf5),
    description: 'Luangkan me-time untuk relaksasi, meditasi, atau hobi '
        'minimal 1x seminggu.',
    confirmLabel: 'Sudah Me-Time',
    targetPerWeek: 1,
    targetPerMonth: 4,
  );

  static const harmoniKeluarga = PenilaianPoint(
    modul: 'tenang',
    kode: 'harmoni_keluarga',
    title: 'Nyalakan Harmoni (Quality Time)',
    emoji: '🏠',
    icon: FontAwesomeIcons.houseUser,
    color: Color(0xfff59e0b),
    softColor: Color(0xfffff8e1),
    description: 'Luangkan quality time bersama keluarga untuk mempererat '
        'hubungan emosional.',
    confirmLabel: 'Sudah Quality Time',
    targetPerWeek: 1,
    targetPerMonth: 4,
  );

  static const akuiEmosi = PenilaianPoint(
    modul: 'tenang',
    kode: 'akui_emosi',
    title: 'Akui Emosi',
    emoji: '💬',
    icon: FontAwesomeIcons.comments,
    color: Color(0xff00a896),
    softColor: Color(0xffe6faf7),
    description: 'Akui dan kenali emosi yang dirasakan (senang, cemas, '
        'kecewa, stres) secara jujur.',
    confirmLabel: 'Sudah Mengakui Emosi',
    targetPerWeek: 1,
    targetPerMonth: 4,
  );

  static const kendaliDiri = PenilaianPoint(
    modul: 'tenang',
    kode: 'kendali_diri',
    title: 'Nyalakan Kendali (Verbal/WA)',
    emoji: '🛡️',
    icon: FontAwesomeIcons.shieldHalved,
    color: Color(0xff2c7eff),
    softColor: Color(0xffe8f0ff),
    description: 'Jaga kendali diri dalam berkomunikasi verbal/WA, '
        'hindari kata-kata yang menyakiti.',
    confirmLabel: 'Sudah Kendali Diri',
    targetPerWeek: 5,
    targetPerMonth: 20,
  );

  static const koneksiSosial = PenilaianPoint(
    modul: 'tenang',
    kode: 'koneksi_sosial',
    title: 'Gaungkan Koneksi (Sosialisasi)',
    emoji: '🤝',
    icon: FontAwesomeIcons.users,
    color: Color(0xff00c368),
    softColor: Color(0xffeefdf5),
    description: 'Bangun koneksi sosial: arisan, jalan bareng, atau '
        'berinteraksi dengan orang lain.',
    confirmLabel: 'Sudah Sosialisasi',
    targetPerWeek: 1,
    targetPerMonth: 4,
  );

  static const semua = <PenilaianPoint>[
    tahanEmosi,
    ekspresiSehat,
    harmoniKeluarga,
    akuiEmosi,
    kendaliDiri,
    koneksiSosial,
  ];
}

/// Ambil daftar titik penilaian berdasarkan modul.
List<PenilaianPoint> penilaianPoints(String modul) {
  return modul == 'tenang'
      ? TenangPenilaianPoints.semua
      : SehatPenilaianPoints.semua;
}
