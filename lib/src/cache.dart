part of firestorex;

/// Collection for querying based on [updatedAt] field, also essential if you
/// are caching with local database([Sqlite], [SharedPreferences], [Hive] etc...).
/// Store queried documents with [dateTime] field so when you query again.
/// A typical query would be:
/// ```dart
/// collection.where('timestamp', isGreaterThan: collectionObject.timestamp);
/// ```
/// Only newer documents will be queried by doing so.
/// [handler] callback will let you manipulate your local database
///
/// todo delete handler
extension FirebaseFirestoreX on FirebaseFirestore {
  CollectionReference<R> cachedCollection<R>({
    required String path,
    required FromJson<R> fromJson,
    required ToJson<R> toJson,
    required FirestoreCacheAddHandler<R> cacheHandler,
    String timestampKey = 'updatedAt',
  }) {
    return collection(path).withConverter<R>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data()!;
        final value = fromJson(data);
        if (data[timestampKey] != null) {
          final ts = const TimestampConv().fromJson(data[timestampKey]);
          cacheHandler(snapshot.id, value, ts);
        }
        return value;
      },
      toFirestore: (R value, _) {
        final json = toJson(value);
        assert(!json.containsKey(timestampKey), '$timestampKey key occupied');
        return json..[timestampKey] = FieldValue.serverTimestamp();
      },
    );
  }
}

extension DocumentReferenceX<R> on DocumentReference<R> {
  Future<void> cachedDelete() async {
    // TODO
    throw UnimplementedError();
  }
}

typedef FirestoreCacheAddHandler<R> = void Function(
  String id,
  R data,
  DateTime timestamp,
);
typedef FirestoreCacheEraseHandler<R> = void Function(
  String id,
  DateTime timestamp,
);
typedef FromJson<R> = R Function(Map<String, dynamic> json);
typedef ToJson<R> = Map<String, dynamic> Function(R value);
