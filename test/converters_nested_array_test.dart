import 'package:firestorex/firestorex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const conv = NestedArrayConv();
  group('NestedArrayConv', () {
    test('fromJson', () {
      expect(conv.fromJson({'0': 9, '1': 8}), [9, 8]);
      expect(conv.fromJson({}), []);
    });

    test('toJson', () {
      expect(conv.toJson([]), {});
      expect(conv.toJson([1, 2, 3]), {'0': 1, '1': 2, '2': 3});
    });
  });
}
