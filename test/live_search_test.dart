// Reads the real sites once, to check the readers still understand them.
// Off by default: run with GRAHA_LIVE=1 flutter test test/live_search_test.dart
// Light on the sites: one results page per site and town, a second apart.

import 'dart:io';

import 'package:anveshana/domain/search_request.dart';
import 'package:anveshana/domain/sources.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// The towns the current test focuses on: Leeds down to Doncaster.
const _towns = ['Leeds', 'Wakefield', 'Pontefract', 'Doncaster'];

/// The sites read over HTTP that cover England (PropertyPal is Northern Ireland).
const _sites = [SourceId.rightmove, SourceId.onTheMarket, SourceId.openRent];

void main() {
  final live = Platform.environment['GRAHA_LIVE'] != null;

  test('the HTTP sites answer for Leeds to Doncaster', skip: live ? false : 'set GRAHA_LIVE=1', () async {
    final client = http.Client();
    final reader = SourceReader(client);
    final report = <String>[];
    var read = 0;
    for (final town in _towns) {
      for (final site in _sites) {
        final q = SearchRequest(area: town, minBeds: 2);
        try {
          final page = await reader.search(site, q);
          final items = page.items;
          read += items.length;
          final priced = items.where((l) => l.price != null).length;
          final placed = items.where((l) => l.lat != null || l.postcode.isNotEmpty).length;
          final first = items.isEmpty ? '' : ' e.g. ${items.first.address} ${items.first.price}';
          report.add(
            '$town / ${site.label}: ${items.length} homes, $priced priced, $placed placed, '
            'more: ${page.more}$first',
          );
        } on Object catch (e) {
          report.add('$town / ${site.label}: ${e.runtimeType} $e');
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    client.close();
    // ignore: avoid_print
    print(report.join('\n'));
    expect(read, greaterThan(0));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
