import 'package:firestorex/src/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('FirestoreString', () {
    test('firestoreSearchQueries', () {
      expect([], ''.textSearchQueries());
      expect([], '       '.textSearchQueries());
      expect([], '---------'.textSearchQueries(sep: '-'));
      expect(['dashx'], 'dashx'.textSearchQueries(minLen: 5));
      expect(
        [
          'das',
          'dash',
          'dashx',
        ],
        'dashx'.textSearchQueries(),
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
        ' Mehmet Esen '.textSearchQueries(),
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
        ' le  petit    déjeuner'.textSearchQueries(minLen: 5),
      );
      expect(
        [
          'dart',
          'go',
          'rust',
          'python',
          'c',
        ],
        'dart,,,,go,,,rust,,python,c'.textSearchQueries(minLen: 6, sep: ','),
      );
    });
  });
}
