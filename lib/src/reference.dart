part of firecraft;

/// Invoked whenever an updated data fetched from the collection
typedef OnFirestoreDocumentData<R> = void Function(
    String id, R value, DateTime? updatedAt);

/// Customized [CollectionReference] for caching strategies based on 'updatedAt'
/// and 'isDeleted' fields. Be sure the consistency of [updatedAtKey] and
/// [isDeletedKey] through operations.
///
/// ```dart
/// collection.where('updatedAt', isGreaterThan: lastCachedObject.timestamp);
/// ```
///
/// Only newer documents will be queried by doing so.
extension FirebaseFirecraft on FirebaseFirestore {
  CollectionReference<R> inventory<R>({
    required String path,
    required R Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(R value) toJson,
    OnFirestoreDocumentData<R>? onData,
    String updatedAtKey = 'updatedAt',
  }) {
    return collection(path).withConverter<R>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data()!;
        final value = fromJson(data);
        if (data.containsKey(updatedAtKey)) {
          onData?.call(
            snapshot.id,
            value,
            const TimestampConv().fromJson(data[updatedAtKey]),
          );
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
  /// Replacement for [DocumentReference.update], automatically adds
  /// [updatedAtKey] timestamp
  Future<void> craft(
    Map<String, dynamic> data, [
    String updatedAtKey = 'updatedAt',
  ]) {
    return update(data..[updatedAtKey] = FieldValue.serverTimestamp());
  }
}

extension TransactionX on Transaction {
  /// Replacement for [Transaction.update], automatically adds [updatedAtKey]
  /// timestamp
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
