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

    test('copyWhere', () {
      final m = UnmodifiableMapView({0: 2, 1: 1, 2: 0});
      expect(m.copyWhere((k, v) => k > 2), UnmodifiableMapView({}));
      expect(m.copyWhere((k, v) => k > 1), UnmodifiableMapView({2: 0}));
      expect(m.copyWhere((k, v) => k < 1), UnmodifiableMapView({0: 2}));
      expect(m.copyWhere((k, v) => v < 2), UnmodifiableMapView({2: 0, 1: 1}));
      expect(m.copyWhere((k, v) => v < 3), m);
    });
  });
}
