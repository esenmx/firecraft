import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firecraft/firecraft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

void main() {
  test('inventory', () async {
    final collection = FakeFirebaseFirestore().inventory<Entity>(
      path: 'test',
      fromJson: (json) => Entity.fromJson(json),
      toJson: (val) => val.toJson(),
      onData: (id, value, timestamp) {
        const d = Duration(milliseconds: 1); // may vary depend on machine
        expect(value.dateTime.withinDuration(timestamp!, d), isTrue);
      },
    );
    for (int i = 0; i < 1000; i++) {
      collection.add(Entity(kFirecraftTimestamp));
    }
  });
}

class Entity {
  final DateTime dateTime;

  Entity(this.dateTime);

  factory Entity.fromJson(Map<String, Object?> json) {
    return Entity(const TimestampConv().fromJson(json['dateTime']));
  }

  Map<String, Object?> toJson() => {'dateTime': FieldValue.serverTimestamp()};
}
