import 'package:firestorex/firestorex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('createIndexes', () {
    expect([], ''.searchIndex());
    expect([], '       '.searchIndex());
    expect([' '], ' ---------'.searchIndex(separator: '-'));
    expect(['test'], 'test'.searchIndex(minLen: 5));
    expect(['tes', 'test'], 'test'.searchIndex(minLen: 3).toList());
    expect(
      ['exam', 'examp', 'exampl', 'example', 'valu', 'value'],
      ' example Value '.searchIndex().toList(),
    );
    expect(
      ['a', 'quick', 'brown'],
      ' a  quick   brown'.searchIndex(minLen: 5).toList(),
    );
    expect(
      ['foo', 'bar', 'baz'],
      'foo,,,,bar,baz'.searchIndex(minLen: 6, separator: ',').toList(),
    );
  });
}
