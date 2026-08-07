import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:employee_wellness/components/hijau_task_card.dart';
import 'package:employee_wellness/components/hijau_scan_card.dart';
import 'package:employee_wellness/config/hijau_scan_points.dart';

void main() {
  testWidgets('HijauTaskCard menampilkan data tugas dan memicu onSelesai',
      (WidgetTester tester) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HijauTaskCard(
            icon: FontAwesomeIcons.lightbulb,
            title: 'Ganti ke Lampu LED',
            difficulty: 'Mudah',
            description: 'Hemat energi listrik.',
            points: 100,
            benefit: 'Hemat 80% energi',
            isCompleted: completed,
            onSelesai: () => completed = true,
          ),
        ),
      ),
    );

    expect(find.text('Ganti ke Lampu LED'), findsOneWidget);
    expect(find.text('+100 Poin'), findsOneWidget);
    expect(find.text('Mudah'), findsOneWidget);

    await tester.tap(find.text('Selesai'));
    expect(completed, isTrue);
  });

  testWidgets('HijauTaskCard menampilkan status selesai saat isCompleted',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HijauTaskCard(
            icon: FontAwesomeIcons.lightbulb,
            title: 'Ganti ke Lampu LED',
            difficulty: 'Mudah',
            description: 'Hemat energi listrik.',
            points: 100,
            isCompleted: true,
            onSelesai: () {},
          ),
        ),
      ),
    );

    // Saat selesai ada 3 FaIcon (ikon task + ikon checklist + ikon koin), bukan tombol.
    expect(find.byType(FaIcon), findsNWidgets(3));
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('HijauScanCard menampilkan wawasan, progress, dan tombol konfirmasi',
      (WidgetTester tester) async {
    var confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HijauScanCard(
              point: HijauScanPoints.gayaHidupHijau,
              doneThisWeek: false,
              loading: false,
              onConfirm: () => confirmed = true,
              weekCount: 0,
              monthCount: 2,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Gaya Hidup Hijau'), findsOneWidget);
    expect(find.text('Tahukah Anda?'), findsOneWidget);
    expect(find.text('+1 Poin'), findsOneWidget);
    expect(find.text('Sudah Melakukan'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);
    expect(find.text('2/4'), findsOneWidget);

    await tester.ensureVisible(find.text('Sudah Melakukan'));
    await tester.pump();
    await tester.tap(find.text('Sudah Melakukan'));
    expect(confirmed, isTrue);
  });

  testWidgets('HijauScanCard nonaktif saat cap mingguan tercapai',
      (WidgetTester tester) async {
    var confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HijauScanCard(
              point: HijauScanPoints.ubahKebiasaan,
              doneThisWeek: true,
              loading: false,
              onConfirm: () => confirmed = true,
              weekCount: 1,
              monthCount: 3,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Selesai minggu ini'), findsWidgets);
    expect(find.text('1/1'), findsOneWidget);

    await tester.tap(find.textContaining('Selesai minggu ini').first,
        warnIfMissed: false);
    expect(confirmed, isFalse);
  });
}

