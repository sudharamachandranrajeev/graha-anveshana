import 'package:anveshana/domain/bank_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CSV cells: quotes, commas, doubled quotes, CRLF', () {
    expect(csvRows('a,"b, c","say ""hi"""\r\n1,2,3\r\n\r\n'), [
      ['a', 'b, c', 'say "hi"'],
      ['1', '2', '3'],
    ]);
  });

  test('UK statement dates', () {
    expect(bankDate('05/11/2026'), '2026-11-05');
    expect(bankDate('5-11-26'), '2026-11-05');
    expect(bankDate('05 Nov 2026'), '2026-11-05');
    expect(bankDate('5-Nov-26'), '2026-11-05');
    expect(bankDate('2026-11-05'), '2026-11-05');
    expect(bankDate('2026-11-05T10:00:00Z'), '2026-11-05');
    expect(bankDate('31/02/2026'), isNull);
    expect(bankDate('Balance'), isNull);
  });

  test('amounts in pence', () {
    expect(bankAmount('£1,050.00'), 105000);
    expect(bankAmount('-20.5'), -2050);
    expect(bankAmount('(20.50)'), -2050);
    expect(bankAmount('950.00 CR'), 95000);
    expect(bankAmount('950.00 DR'), -95000);
    expect(bankAmount(''), isNull);
  });

  test('one signed Amount column, details above the headings', () {
    const csv =
        'Account,12345678\n\n'
        'Date,Counter Party,Reference,Type,Amount (GBP),Balance (GBP)\n'
        '01/10/2026,J SMITH,RENT OCT,FASTER PAYMENT,950.00,1950.00\n'
        '03/10/2026,TESCO,,CARD,-42.10,1907.90\n';
    final s = parseStatement(csv);
    expect(s.error, isNull);
    expect(s.lines, [
      const BankLine('2026-10-01', 95000, 'J SMITH RENT OCT'),
      const BankLine('2026-10-03', -4210, 'TESCO'),
    ]);
  });

  test('separate Paid in and Paid out columns', () {
    const csv =
        '"Date","Transaction type","Description","Paid out","Paid in","Balance"\n'
        '"01 Oct 2026","Bank credit","SMITH J","","£950.00","£1,950.00"\n'
        '"02 Oct 2026","Direct debit","LEEDS CC","£150.00","","£1,800.00"\n';
    final s = parseStatement(csv);
    expect([for (final l in s.lines) l.amount], [95000, -15000]);
  });

  test('says what is missing', () {
    expect(parseStatement('a,b\n1,2').error, contains('Date'));
    expect(parseStatement('Date,Note\n01/10/2026,x').error, contains('Amount'));
  });

  test('picks the rent and skips what is recorded', () {
    const lines = [
      BankLine('2026-09-01', 95000, 'OLD TENANT'), // before the start
      BankLine('2026-10-01', 95000, 'FASTER PAYMENT'), // full rent
      BankLine('2026-10-15', 20000, 'SMITH J PART'), // names the tenant
      BankLine('2026-10-20', 20000, 'REFUND'), // neither
      BankLine('2026-11-01', 95000, 'RENT'), // already recorded
      BankLine('2026-11-02', -95000, 'TRANSFER'), // money out
    ];
    final found = rentLines(
      lines,
      received: true,
      rent: 950,
      start: '2026-10-01',
      otherParty: 'Mrs Jane Smith',
      recorded: [(date: '2026-11-01', amount: 950)],
    );
    expect([for (final l in found) l.date], ['2026-10-01', '2026-10-15']);
    expect(rentLines(lines, received: false, rent: 950, start: '2026-10-01').single.date, '2026-11-02');
  });
}
