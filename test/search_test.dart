import 'package:firestorex/firestorex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('createIndexes', () {
    expect([], ''.searchableStrings());
    expect([], '       '.searchableStrings());
    expect([' '], ' ---------'.searchableStrings(separator: '-'));
    expect(['test'], 'test'.searchableStrings(minKeywordLength: 5));
    expect(['tes', 'test'], 'test'.searchableStrings().toList());
    expect(
      ['exam', 'examp', 'exampl', 'example', 'valu', 'value'],
      ' example Value '.searchableStrings(minKeywordLength: 4).toList(),
    );
    expect(
      ['a', 'quick', 'brown'],
      ' a  quick   brown'.searchableStrings(minKeywordLength: 5).toList(),
    );
    expect(
      ['foo', 'bar', 'baz'],
      'foo,,,,bar,baz'
          .searchableStrings(minKeywordLength: 6, separator: ',')
          .toList(),
    );
  });
}
