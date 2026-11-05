import 'package:anveshana/domain/local_rules.dart';
import 'package:anveshana/domain/research.dart';
import 'package:flutter_test/flutter_test.dart';

Place place(String district, {String ward = ''}) =>
    Place(postcode: 'X1 1XX', lat: 53.7, lon: -1.5, country: 'England', district: district, ward: ward);

void main() {
  test('benefit rates and rents are found by council name', () {
    expect(lhaFor('Wakefield')?.b2, 595);
    expect(lhaFor('City of Bradford')?.area, 'Bradford and South Dales');
    expect(lhaFor('Cornwall'), isNull);
    expect(lhaRate(lhaFor('Doncaster')!, 2), 500);
    expect(lhaRate(lhaFor('Doncaster')!, 0), 304.17);
    expect(lhaRate(lhaFor('Doncaster')!, 6), 725);
    expect(rentFor('Doncaster', 2), (forBeds: 641, average: 699));
    expect(rentFor('Leeds', 2), (forBeds: null, average: 1148));
    expect(rentFor('Nowhere', 1), (forBeds: null, average: null));
  });

  test('gross yield', () {
    expect(grossYield(699, 173000), closeTo(4.85, 0.01));
    expect(grossYield(500, 0), 0);
  });

  test('Leeds licensing is a caution only in the listed wards', () {
    final armley = localNotes(place('Leeds', ward: 'Armley')).first;
    expect(armley.concern, Concern.caution);
    expect(localNotes(place('Leeds', ward: 'Beeston & Holbeck')).first.concern, Concern.caution);
    final headingley = localNotes(place('Leeds', ward: 'Headingley and Hyde Park')).first;
    expect(headingley.concern, Concern.info);
  });

  test('Doncaster flags Hexthorpe; unknown councils say nothing', () {
    expect(localNotes(place('Doncaster', ward: 'Hexthorpe and Balby North')).first.concern, Concern.caution);
    expect(localNotes(place('Doncaster', ward: 'Town')).first.concern, Concern.info);
    expect(localNotes(place('Cornwall')), isEmpty);
    expect(localNotes(place('Wakefield')).first.text, contains('Article 4'));
  });
}
