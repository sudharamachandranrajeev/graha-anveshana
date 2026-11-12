import 'package:anveshana/app/search_memory.dart';
import 'package:anveshana/domain/book.dart';
import 'package:anveshana/domain/search_request.dart';
import 'package:brahma_core/brahma_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('a different search with the same name is numbered, not replaced', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final book = PropertyBook(await Store.open(db));
    Future<List<String>> names() async => [
      for (final j in await book.pref<List<Object?>>(PrefKeys.savedSearches, const []))
        (j as Map)['name'] as String,
    ];
    await saveSearch(book, const [], 'Leeds flats', readRequest('flat to rent in Leeds with parking'), null);
    final first = savedFromJson(await book.pref<List<Object?>>(PrefKeys.savedSearches, const []));
    await saveSearch(book, first, 'Leeds flats', readRequest('flat to rent in Leeds with a garden'), null);
    expect(await names(), ['Leeds flats', 'Leeds flats (2)']);
    // The same search saved again is renamed in place.
    final two = savedFromJson(await book.pref<List<Object?>>(PrefKeys.savedSearches, const []));
    await saveSearch(book, two, 'Parking', readRequest('flat to rent in Leeds with parking'), null);
    expect(await names(), ['Parking', 'Leeds flats (2)']);
  });
}
