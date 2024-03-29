import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firecraft/firecraft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rand/rand.dart';

void main() async {
  final fake = FakeFirebaseFirestore();
  final collection = fake.collection('test');
  group('TimestampConv', () {
    final toJson = const TimestampConv().toJson;
    final fromJson = const TimestampConv().fromJson;

    test('serverTimestamp', () async {
      final doc = collection.doc();
      await doc.set({'timestamp': toJson(kFirecraftTimestamp)});
      final json = await doc.get().then((value) => value.data());

      expect(fromJson(json?['timestamp']), isA<DateTime>());
      expect(
        fromJson(json?['timestamp']).microsecondsSinceEpoch,
        greaterThan(_secBefore.microsecondsSinceEpoch),
      );
      expect(
        fromJson(json?['timestamp']).microsecondsSinceEpoch,
        lessThan(_secAfter.microsecondsSinceEpoch),
      );
    });

    test('non serverTimestamp', () async {
      final doc = collection.doc();
      final value = Rand.dateTime();

      await doc.set({'timestamp': toJson(value)});
      final json = await doc.get().then((value) => value.data());

      expect(value, fromJson(json?['timestamp']));
    });
  });

  group('NullTimestampConv', () {
    final toJson = const TimestampNConv().toJson;
    final fromJson = const TimestampNConv().fromJson;

    test('null value', () async {
      final doc = collection.doc();
      await doc.set({'timestamp': null});
      final json = await doc.get().then((value) => value.data());
      expect(fromJson(json?['timestamp']), null);
    });

    test('serverTimestamp', () async {
      final doc = collection.doc();
      await doc.set({'timestamp': toJson(kFirecraftTimestamp)});
      final json = await doc.get().then((value) => value.data());

      expect(fromJson(json?['timestamp']), isA<DateTime>());
      expect(
        fromJson(json?['timestamp'])?.microsecondsSinceEpoch,
        greaterThan(_secBefore.microsecondsSinceEpoch),
      );
      expect(
        fromJson(json?['timestamp'])?.microsecondsSinceEpoch,
        lessThan(_secAfter.microsecondsSinceEpoch),
      );
    });

    test('non serverTimestamp', () async {
      final doc = collection.doc();
      final value = Rand.dateTime();

      await doc.set({'timestamp': toJson(value)});
      final json = await doc.get().then((value) => value.data());

      expect(value, fromJson(json?['timestamp']));
    });
  });
}

DateTime get _secAfter => DateTime.now().add(const Duration(seconds: 1));

DateTime get _secBefore => DateTime.now().add(const Duration(seconds: -1));
