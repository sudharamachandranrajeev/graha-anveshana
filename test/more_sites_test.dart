import 'package:anveshana/domain/more_sites.dart';
import 'package:anveshana/domain/search_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<String> labels(SearchRequest q) => [for (final l in moreSiteLinks(q)) l.label];
  String url(SearchRequest q, String label) => '${moreSiteLinks(q).firstWhere((l) => l.label == label).url}';

  test('to rent: flat-shares at the town, and the council site for Leeds or Doncaster', () {
    const leeds = SearchRequest(area: 'Leeds');
    expect(labels(leeds), ['SpareRoom', 'Leeds Homes', 'Home.co.uk']);
    expect(url(leeds, 'SpareRoom'), 'https://www.spareroom.co.uk/flatshare/leeds');
    expect(labels(const SearchRequest(area: 'DN1 1AA')), ['SpareRoom', 'Doncaster HomeChoice', 'Home.co.uk']);
    expect(url(const SearchRequest(area: 'DN1 1AA'), 'SpareRoom'), 'https://www.spareroom.co.uk');
    expect(labels(const SearchRequest(area: 'Wakefield')), ['SpareRoom', 'Home.co.uk']);
  });

  test('to buy: shared ownership and auctions', () {
    const q = SearchRequest(area: 'Pontefract, West Yorkshire', rent: false);
    expect(labels(q), ['Share to Buy', 'Allsop', 'BTG Eddisons', 'EIG', 'Auction House', 'Home.co.uk']);
    expect(url(q, 'Share to Buy'), 'https://www.sharetobuy.com/locations/pontefract');
  });
}
