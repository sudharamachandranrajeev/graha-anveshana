import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:brahma_core/brahma_core.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdfrx/pdfrx.dart';

import '../domain/catalog.dart';

/// Reading captured files on this device: text from pictures (OCR) and
/// PDFs, and a hash of the main picture. Nothing leaves the device here;
/// [aiFields] is the one optional step that does, and only when asked.

class RecognitionException implements Exception, UserFacingError {
  RecognitionException(this.message);
  @override
  final String message;
  @override
  String toString() => message;
}

/// What came out of a file.
class Capture {
  const Capture({required this.kind, required this.text, this.image, this.imageHash, this.title = ''});

  /// photo or document.
  final String kind;
  final String text, title;

  /// The picture to keep (the photo, or a PDF's first page), as PNG or JPEG.
  final Uint8List? image;
  final String? imageHash;

  ItemFields get fields => readFields(text);
}

const _pictures = {'png', 'jpg', 'jpeg', 'webp', 'bmp', 'gif', 'tif', 'tiff'};

/// The file types Add from file offers.
const captureExtensions = [..._pictures, 'pdf', 'txt', 'eml', 'html', 'htm'];

String _ext(String path) => path.split('.').last.toLowerCase();

/// Reads [path]: a picture is OCR'd, a PDF gives its text (OCR'ing pages
/// that are only pictures), and text files are read as they are.
Future<Capture> recogniseFile(String path) async {
  final ext = _ext(path);
  final name = path.split(Platform.pathSeparator).last;
  if (_pictures.contains(ext)) {
    final bytes = await File(path).readAsBytes();
    return Capture(
      kind: 'photo',
      title: name,
      text: await ocrPicture(path),
      image: bytes,
      imageHash: await pictureHash(bytes),
    );
  }
  if (ext == 'pdf') return _readPdf(path, name);
  final raw = await File(path).readAsString();
  final text = ext.startsWith('htm') ? textOfHtml(raw) : raw;
  return Capture(kind: 'document', title: name, text: text);
}

/// The words of an HTML page, without its tags, scripts and styles.
String textOfHtml(String html) => html
    .replaceAll(RegExp(r'<(script|style)[^>]*>[\s\S]*?</\1>', caseSensitive: false), ' ')
    .replaceAll(RegExp(r'<br\s*/?>|</(p|div|li|h\d|tr)>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'<[^>]+>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&pound;', '£')
    .replaceAll(RegExp(r'[ \t]+'), ' ')
    .replaceAll(RegExp(r' *\n *'), '\n')
    .replaceAll(RegExp(r'\n\n+'), '\n')
    .trim();

/// Text in a picture: ML Kit on Android, Tesseract on the desktop.
Future<String> ocrPicture(String path) async {
  if (Platform.isAndroid || Platform.isIOS) {
    final reader = TextRecognizer();
    try {
      return (await reader.processImage(InputImage.fromFilePath(path))).text;
    } finally {
      await reader.close();
    }
  }
  final tesseract = _tesseract();
  if (tesseract == null) {
    throw RecognitionException(
      Platform.isWindows
          ? 'Reading pictures needs Tesseract OCR. Install it from github.com/UB-Mannheim/tesseract, then try again.'
          : 'Reading pictures needs Tesseract OCR. Install the "tesseract" and "tesseract-data-eng" '
                'packages (Arch) or "tesseract-ocr" (Debian, Ubuntu), then try again.',
    );
  }
  final r = await Process.run(tesseract, [path, 'stdout', '-l', 'eng'], stdoutEncoding: utf8);
  if (r.exitCode != 0) throw RecognitionException('Tesseract could not read the picture: ${r.stderr}'.trim());
  return '${r.stdout}';
}

String? _tesseract() {
  final dirs = (Platform.environment['PATH'] ?? '').split(Platform.isWindows ? ';' : ':');
  final names = Platform.isWindows ? ['tesseract.exe'] : ['tesseract'];
  for (final d in [...dirs, if (Platform.isWindows) r'C:\Program Files\Tesseract-OCR']) {
    for (final n in names) {
      final f = File('$d${Platform.pathSeparator}$n');
      if (f.existsSync()) return f.path;
    }
  }
  return null;
}

Future<Capture> _readPdf(String path, String name) async {
  await pdfrxFlutterInitialize();
  final doc = await PdfDocument.openFile(path);
  final text = StringBuffer();
  Uint8List? first;
  try {
    for (final page in doc.pages.take(20)) {
      final words = (await page.loadText())?.fullText.trim() ?? '';
      final needsOcr = words.length < 20;
      if (needsOcr || first == null) {
        final png = await _renderPage(page);
        first ??= png;
        if (needsOcr && png != null) {
          final tmp = File(
            '${Directory.systemTemp.path}${Platform.pathSeparator}anveshana-page-${page.pageNumber}.png',
          );
          await tmp.writeAsBytes(png);
          try {
            text.writeln(await ocrPicture(tmp.path));
          } on RecognitionException {
            // A PDF with some text still helps without OCR.
          } finally {
            if (tmp.existsSync()) await tmp.delete();
          }
          continue;
        }
      }
      text.writeln(words);
    }
  } finally {
    await doc.dispose();
  }
  return Capture(
    kind: 'document',
    title: name,
    text: text.toString(),
    image: first,
    imageHash: first == null ? null : await pictureHash(first),
  );
}

/// A page as PNG, about 1600 pixels wide (enough for OCR).
Future<Uint8List?> _renderPage(PdfPage page) async {
  final scale = 1600 / page.width;
  final img = await page.render(
    fullWidth: page.width * scale,
    fullHeight: page.height * scale,
    backgroundColor: 0xffffffff,
  );
  if (img == null) return null;
  try {
    final ui = await img.createImage();
    final data = await ui.toByteData(format: _png);
    ui.dispose();
    return data?.buffer.asUint8List();
  } finally {
    img.dispose();
  }
}

const _png = ui.ImageByteFormat.png;

/// A difference hash of a picture: 64 bits, as 16 hex digits. Pictures of
/// the same photo, resized or recompressed, differ by a few bits.
Future<String?> pictureHash(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 9, targetHeight: 8);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    frame.image.dispose();
    if (data == null) return null;
    final grey = [
      for (var i = 0; i < 72; i++)
        data.getUint8(i * 4) * 299 + data.getUint8(i * 4 + 1) * 587 + data.getUint8(i * 4 + 2) * 114,
    ];
    var hash = BigInt.zero;
    for (var y = 0; y < 8; y++) {
      for (var x = 0; x < 8; x++) {
        hash = hash << 1;
        if (grey[y * 9 + x] > grey[y * 9 + x + 1]) hash |= BigInt.one;
      }
    }
    // A flat picture (a screenshot of text, a blank page) has few edges, so
    // every such picture would look alike: give it no hash at all.
    final edges = hash.toRadixString(2).replaceAll('0', '').length;
    if (edges < 8 || edges > 56) return null;
    return hash.toRadixString(16).padLeft(16, '0');
  } on Object {
    return null;
  }
}

const _aiSystem =
    'You read UK property adverts. Reply with one JSON object and nothing else, using only these keys when the '
    'text says them: address, postcode, price (a whole number of pounds), period ("pcm", "pw" or "" for a sale), '
    'beds, baths, councilTaxBand (A-I), epc (A-G), phone, agent, availableFrom, furnished '
    '("furnished", "part" or "unfurnished"), status ("toLet", "letAgreed", "forSale", "saleAgreed" or "sold"). '
    'Leave out anything the text does not say. Never guess.';

/// Asks the user's own AI (the Ask AI setup) to read [text]. Only [text] is
/// sent. The result fills gaps the on-device reader left; it never
/// replaces what that reader found.
Future<ItemFields> aiFields(HelpAsker asker, String text) async {
  final clipped = text.length > 12000 ? text.substring(0, 12000) : text;
  final answer = await asker.ask(_aiSystem, [(user: true, text: clipped)]);
  final start = answer.indexOf('{'), end = answer.lastIndexOf('}');
  if (start < 0 || end <= start) throw RecognitionException('The AI did not answer with details.');
  try {
    final j = (jsonDecode(answer.substring(start, end + 1)) as Map).cast<String, Object?>();
    return ItemFields.fromJson(j);
  } on FormatException {
    throw RecognitionException('The AI did not answer with details.');
  }
}
