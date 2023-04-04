part of firecraft;

/// Customized [CollectionReference] for caching strategies based on 'updatedAt'
/// field. Be sure the consistency of [updatedAtKey] through operations.
///
/// ```dart
/// collection.where('updatedAt', isGreaterThan: lastCachedObject.timestamp);
/// ```
/// Only newer documents will be queried by doing so.
/// [handler] callback will let you manipulate your local database
extension FirebaseFirecraft on FirebaseFirestore {
  CollectionReference<R> inventory<R>({
    required String path,
    required R Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(R value) toJson,
    required void Function(String id, R data, DateTime? updatedAt)? onData,
    String updatedAtKey = 'updatedAt',
  }) {
    return collection(path).withConverter<R>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data()!;
        final value = fromJson(data);
        if (onData != null && data[updatedAtKey] != null) {
          final ts = const TimestampConv().fromJson(data[updatedAtKey]);
          onData.call(snapshot.id, value, ts);
        }
        return value;
      },
      toFirestore: (R value, _) {
        final json = toJson(value);
        assert(!json.containsKey(updatedAtKey), '$updatedAtKey key conflict');
        return json..[updatedAtKey] = FieldValue.serverTimestamp();
      },
    );
  }
}

extension DocumentReferenceX<T> on DocumentReference<T> {
  Future<void> craft(
    Map<String, dynamic> data, [
    String updatedAtKey = 'updatedAt',
  ]) {
    return update(data..[updatedAtKey] = FieldValue.serverTimestamp());
  }
}

extension TransactionX on Transaction {
  Transaction craft(
    DocumentReference documentReference,
    Map<String, Object?> data, [
    String updatedAtKey = 'updatedAt',
  ]) {
    return update(
      documentReference,
      data..[updatedAtKey] = FieldValue.serverTimestamp(),
    );
  }
}
