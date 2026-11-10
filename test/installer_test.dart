import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the Windows installer has its own id and a findable Start menu name', () {
    final iss = File('windows/installer/anveshana.iss').readAsStringSync();
    final id = RegExp(r'^AppId=\{\{([0-9A-F-]{36})\}', multiLine: true).firstMatch(iss)?.group(1);
    expect(id, 'F96051B1-6F25-4804-B685-5FC768E030C1');
    // Ids other Brahma apps use: sharing one makes Windows treat two apps as
    // one (same folder, shortcuts and uninstaller).
    const others = {
      '55825A17-B296-4ED6-A66E-84FB1F5A100C', // Bhojana (also Udyoga, Vidya)
      '1BFC6395-2669-4958-84C2-909F48B0B533', // Vahana Anveshana
      '6DAAFB0C-B2A5-440A-92B9-370050674767', // Brahma
    };
    expect(others, isNot(contains(id)));
    expect(iss, contains(r'Name: "{autoprograms}\Graha Anveshana"'));
  });
}
