part of firecraft;

/// Customized [CollectionReference] for caching strategies based on 'updatedAt'
/// field. Please be sure consistency of [updatedAtKey] through operations.
///
/// ```dart
/// collection.where('updatedAt', isGreaterThan: collectionObject.timestamp);
/// ```
/// Only newer documents will be queried by doing so.
/// [handler] callback will let you manipulate your local database
extension FirebaseFirestoreX on FirebaseFirestore {
  CollectionReference<R> cachedCollection<R>({
    required String path,
    required R Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(R value) toJson,
    required void Function(String id, R data, DateTime updatedAt) onData,
    String updatedAtKey = 'updatedAt',
  }) {
    return collection(path).withConverter<R>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data()!;
        final value = fromJson(data);
        if (data[updatedAtKey] != null) {
          final ts = const TimestampConv().fromJson(data[updatedAtKey]);
          onData(snapshot.id, value, ts);
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
  Future<void> cachedUpdate(
    Map<String, Object?> data, [
    String updatedAtKey = 'updatedAt',
  ]) {
    return update(data..[updatedAtKey] = FieldValue.serverTimestamp());
  }
}

extension TransactionX on Transaction {
  Transaction cachedUpdate(
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
