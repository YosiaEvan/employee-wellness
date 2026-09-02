import 'dart:ui' as ui;

import 'package:employee_wellness/components/chroma_key_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('animated webp decodes with alpha and multiple frames', () async {
    final data = await rootBundle.load('assets/videos/animasi_transparent.webp');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    debugPrint('frameCount=${codec.frameCount}');
    expect(codec.frameCount, greaterThan(1));

    final frame = await codec.getNextFrame();
    final img = frame.image;
    debugPrint('size=${img.width}x${img.height}');
    expect(img.width, greaterThan(0));

    final byteData = await img.toByteData();
    final px = byteData!.buffer.asUint8List();
    final corner = px.sublist(0, 4);
    final centerIdx = ((img.height ~/ 2) * img.width + img.width ~/ 2) * 4;
    final center = px.sublist(centerIdx, centerIdx + 4);
    debugPrint('corner RGBA=$corner center RGBA=$center');
    expect(corner[3], lessThan(10));
    expect(center[3], greaterThan(200));
  });

  testWidgets('ChromaKeyVideo hanya merender satu frame aktif', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ChromaKeyVideo())));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await tester.pump();
      expect(find.byType(RawImage), findsOneWidget);
      final first = tester.widget<RawImage>(find.byType(RawImage)).image;
      expect(first, isNotNull);

      await Future<void>.delayed(const Duration(milliseconds: 250));
      await tester.pump();
      final second = tester.widget<RawImage>(find.byType(RawImage)).image;
      expect(second, isNotNull);
      expect(identical(first, second), isFalse);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.byType(RawImage), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
