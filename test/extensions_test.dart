import 'package:firestorex/firestorex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('createIndexes', () {
    expect([], ''.createIndexes());
    expect([], '       '.createIndexes());
    expect([], '---------'.createIndexes(separator: '-'));
    expect(['dashx'], 'dashx'.createIndexes(elementLength: 5));
    expect(
      [
        'das',
        'dash',
        'dashx',
      ],
      'dashx'.createIndexes().toList(),
    );
    expect(
      [
        'meh',
        'mehm',
        'mehme',
        'mehmet',
        'ese',
        'esen',
      ],
      ' Mehmet Esen '.createIndexes().toList(),
    );
    expect(
      [
        'le',
        'petit',
        'déjeu',
        'déjeun',
        'déjeune',
        'déjeuner',
      ],
      ' le  petit    déjeuner'.createIndexes(elementLength: 5).toList(),
    );
    expect(
      ['dart', 'go', 'rust&c'],
      'dart,,,,go,rust&c'
          .createIndexes(elementLength: 6, separator: ',')
          .toList(),
    );
  });
}
