import 'package:firecraft/firecraft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';

class _Conv implements JsonConverter<int, int> {
  const _Conv();

  @override
  int fromJson(int json) => json;

  @override
  int toJson(int object) => object;
}

void main() {
  group('ArrayConv', () {
    const conv = NestedArrayConv<int, int>(_Conv());
    test('fromJson', () {
      expect(conv.fromJson({'0': 9, '1': 8}), [9, 8]);
      expect(conv.fromJson({}), []);
      expect(conv.fromJson({'1': 0}), [0]);
    });

    test('toJson', () {
      expect(conv.toJson([]), {});
      expect(conv.toJson([1, 2, 3]), {'0': 1, '1': 2, '2': 3});
    });
  });

  group('NestedArrayConv', () {
    const conv =
        NestedArrayConv<List<int>, Map>(NestedArrayConv<int, int>(_Conv()));
    test('fromJson', () {
      expect(
          conv.fromJson({
            '0': {'0': 1},
            '1': {},
          }),
          [
            [1],
            [],
          ]);
      expect(conv.fromJson({}), []);
      expect(conv.fromJson({'1': {}}), [[]]);
    });

    test('toJson', () {
      expect(conv.toJson([]), {});
      expect(
          conv.toJson([
            [1, 2],
            [],
          ]),
          {
            '0': {'0': 1, '1': 2},
            '1': {},
          });
    });
  });
}
