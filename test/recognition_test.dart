import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:anveshana/app/recognition.dart';
import 'package:anveshana/domain/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

/// A made-up advert drawn as a screenshot would be.
Future<List<int>> _screenshot(List<String> lines) async {
  final loader = FontLoader('Inter')
    ..addFont(File('assets/fonts/Inter-Regular.ttf').readAsBytes().then((b) => ByteData.sublistView(b)));
  await loader.load();
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec)..drawColor(Colors.white, BlendMode.src);
  var y = 30.0;
  for (final l in lines) {
    final tp = TextPainter(
      text: TextSpan(
        text: l,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 34, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(30, y));
    y += 56;
  }
  final img = await rec.endRecording().toImage(1100, y.toInt() + 30);
  return (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

const _pdfium = 'build/linux/x64/release/bundle/lib/libpdfium.so';

void main() {
  final hasTesseract = Process.runSync('sh', ['-c', 'command -v tesseract']).exitCode == 0;

  test('a screenshot of an advert becomes its details', () async {
    final dir = await Directory.systemTemp.createTemp('anveshana-ocr');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/advert.png');
    final png = await _screenshot([
      '14 Sample Street, Exampletown BT74 1AA',
      '£650 pcm',
      '2 bedroom apartment to let',
      'Council Tax Band: C',
      'EPC rating D',
    ]);
    await file.writeAsBytes(png);
    final cap = await recogniseFile(file.path);
    expect(cap.kind, 'photo');
    // Text on white is too flat to hash (it would match every other screenshot).
    expect(cap.imageHash, isNull);
    final f = cap.fields;
    expect(f.postcode, 'BT74 1AA');
    expect((f.price, f.period, f.beds), (650, 'pcm', 2));
    expect((f.councilTaxBand, f.epc), ('C', 'D'));
  }, skip: hasTesseract ? false : 'tesseract is not installed');

  test('photos hash alike when resized; different photos and flat pictures do not', () async {
    Future<Uint8List> photo(int seed, {int size = 400}) async {
      final rec = ui.PictureRecorder();
      final canvas = Canvas(rec);
      final rnd = math.Random(seed);
      for (var i = 0; i < 40; i++) {
        canvas.drawRect(
          Rect.fromLTWH(rnd.nextDouble() * size, rnd.nextDouble() * size, size / 3, size / 4),
          Paint()..color = Color(0xff000000 | rnd.nextInt(0xffffff)),
        );
      }
      final img = await rec.endRecording().toImage(size, size);
      return (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    }

    final a = await pictureHash(await photo(1));
    final smaller = await pictureHash(await photo(1, size: 300));
    final other = await pictureHash(await photo(2));
    expect(a, isNotNull);
    expect(hashDistance(a, smaller), 0);
    expect(hashDistance(a, other), greaterThan(6));
    expect(await pictureHash(Uint8List.fromList(await _screenshot(['£650 pcm']))), isNull);
  });

  test(
    'a PDF brochure gives its text and a first-page picture',
    () async {
      final dir = await Directory.systemTemp.createTemp('anveshana-pdf');
      addTearDown(() => dir.delete(recursive: true));
      final png = File('${dir.path}/page.png');
      await png.writeAsBytes(
        await _screenshot(['Brochure', '£185,000', '3 bedroom semi for sale', 'BT74 1AA']),
      );
      // Tesseract writes a searchable PDF: the picture with its text layer.
      final r = await Process.run('tesseract', [png.path, '${dir.path}/brochure', 'pdf']);
      expect(r.exitCode, 0, reason: '${r.stderr}');
      // Tests have no app cache folder or bundled PDFium: use the build's.
      Pdfrx.cacheDirectoryPath = dir.path;
      Pdfrx.pdfiumModulePath = _pdfium;
      final cap = await recogniseFile('${dir.path}/brochure.pdf');
      expect(cap.kind, 'document');
      expect(cap.image, isNotNull);
      expect((cap.fields.price, cap.fields.beds, cap.fields.postcode), (185000, 3, 'BT74 1AA'));
    },
    skip: !hasTesseract
        ? 'tesseract is not installed'
        : (!File(_pdfium).existsSync() ? 'build the Linux app first' : false),
  );

  test('HTML pages are read as their words', () {
    expect(textOfHtml('<p>£700&nbsp;pcm</p><script>x()</script><div>2 bed</div>'), '£700 pcm\n2 bed');
  });
}
