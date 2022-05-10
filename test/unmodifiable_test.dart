import 'dart:collection';

import 'package:firestorex/firestorex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnmodifiableMap', () {
    test('copySetBatch', () {
      final m = UnmodifiableMapView({1: 'a', 2: 'b', 3: 'c'});
      final nm = m.copySetBatch(const [MapEntry(1, 'c'), MapEntry(2, 'd')]);
      expect(nm[1], 'c');
      expect(nm[2], 'd');
      expect(nm[3], 'c');
    });
  });
}
