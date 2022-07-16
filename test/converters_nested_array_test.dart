import 'package:firestorex/firestorex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArrayConv', () {
    const conv = ArrayConv();

    test('fromJson', () {
      expect(conv.fromJson({'0': 9, '1': 8}), [9, 8]);
      expect(conv.fromJson({}), []);
      expect(() => conv.fromJson({'1': 0}), throwsA(isA<AssertionError>()));
    });

    test('toJson', () {
      expect(conv.toJson([]), {});
      expect(conv.toJson([1, 2, 3]), {'0': 1, '1': 2, '2': 3});
    });
  });

  group('NestedArrayConv', () {
    const conv = NestedArrayConv();

    test('fromJson', () {
      expect(
          conv.fromJson({
            '0': {'0': 1},
            '1': {}
          }),
          [
            [1],
            []
          ]);
      expect(conv.fromJson({}), []);
      expect(() => conv.fromJson({'1': {}}), throwsA(isA<AssertionError>()));
    });

    test('toJson', () {
      expect(conv.toJson([]), {});
      expect(
          conv.toJson([
            [1, 2],
            []
          ]),
          {
            '0': {'0': 1, '1': 2},
            '1': {},
          });
    });
  });
}
