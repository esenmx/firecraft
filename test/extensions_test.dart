import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firestorex/firestorex.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  test('createIndexes', () {
    expect([], ''.searchIndexer());
    expect([], '       '.searchIndexer());
    expect([' '], ' ---------'.searchIndexer(separator: '-'));
    expect(['test'], 'test'.searchIndexer(slize: 5));
    expect(['tes', 'test'], 'test'.searchIndexer(slize: 3).toList());
    expect(
      ['exam', 'examp', 'exampl', 'example', 'valu', 'value'],
      ' example Value '.searchIndexer().toList(),
    );
    expect(
      ['a', 'quick', 'brown'],
      ' a  quick   brown'.searchIndexer(slize: 5).toList(),
    );
    expect(
      ['foo', 'bar', 'baz'],
      'foo,,,,bar,baz'.searchIndexer(slize: 6, separator: ',').toList(),
    );
  });

  testWidgets('cachedCollection', (t) async {
    final collection = FakeFirebaseFirestore().cachedCollection<Entity>(
      path: 'test',
      fromJson: (json) => Entity.fromJson(json),
      toJson: (val) => val.toJson(),
      cacheHandler: (id, val, ts) {
        const d = Duration(milliseconds: 1); // may vary depend on machine
        expect(val.dateTime.withinDuration(ts, d), isTrue);
      },
    );
    for (int i = 0; i < 1000; i++) {
      collection.add(Entity(kServerTimestampSentinel));
    }
  });
}

class Entity {
  final DateTime dateTime;

  Entity(this.dateTime);

  factory Entity.fromJson(Map<String, Object?> json) {
    return Entity(timestampConv.fromJson(json['dateTime']));
  }

  Map<String, Object?> toJson() => {'dateTime': FieldValue.serverTimestamp()};
}
