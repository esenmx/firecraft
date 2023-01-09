import 'package:firecraft/firecraft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('createIndexes', () {
    expect([], ''.strings());
    expect([], '       '.strings());
    expect([' '], ' ---------'.strings(separator: '-'));
    expect(['test'], 'test'.strings(minKeywordLength: 5));
    expect(['tes', 'test'], 'test'.strings().toList());
    expect(
      ['exam', 'examp', 'exampl', 'example', 'valu', 'value'],
      ' example Value '.strings(minKeywordLength: 4).toList(),
    );
    expect(
      ['a', 'quick', 'brown'],
      ' a  quick   brown'.strings(minKeywordLength: 5).toList(),
    );
    expect(
      ['foo', 'bar', 'baz'],
      'foo,,,,bar,baz'.strings(minKeywordLength: 6, separator: ',').toList(),
    );
  });
}
