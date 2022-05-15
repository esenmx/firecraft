part of firestorex;

extension TextSearchX on String {
  /// An opinionated way to handle text searches in [Firestore]
  ///
  /// [minLen] stands for number of minimum characters that required for search
  /// [separator] is word separator, typically a white space
  ///
  /// Instead bloating your model with and extra field, mutate your [toJson]
  /// method within converter via [textSearchArray] or [textSearchMap]
  /// Best practise example:
  /// ```dart
  /// final memberCollection = firestore.collection('member').withConverter<Member>(
  ///       fromFirestore: (snapshot, options) => Member.fromJson(snapshot.data()!),
  ///       toFirestore: (value, options) {
  ///         return value.toJson()..['search'] = value.displayName.textSearchMap();
  ///       },
  ///     );
  /// ```
  @visibleForTesting
  Iterable<String> searchIndex({int minLen = 4, String separator = ' '}) sync* {
    assert(minLen > 1, 'minimum length must be greater than 1');

    for (var s in _prepareForIndex(separator)) {
      if (s.length > minLen) {
        var buffer = StringBuffer(s.substring(0, minLen - 1));
        for (int i = minLen - 1; i < s.length; i++) {
          buffer.writeCharCode(s.codeUnitAt(i));
          yield buffer.toString();
        }
        buffer.clear();
      } else {
        yield s;
      }
    }
  }

  /// Eliminates empty split strings and lowercase all of them
  /// [toLowerCase()] eliminates conflicts like Turkish i-İ, English i-I
  Iterable<String> _prepareForIndex(String separator) {
    return split(separator)
        .where((e) => e.isNotEmpty)
        .map((e) => e.toLowerCase());
  }

  /// For [contains]/[containsAny] element
  ///
  /// Example:
  /// ```dart
  /// final collection = firestore.collection('objects').withConverter<Model>(
  ///   fromFirestore: (snapshot, options) => Model.fromJson(snapshot.data()!),
  ///   toFirestore: (model, options) {
  ///     return model.toJson()
  ///       ..['search'] = model.text.textSearchArray();
  ///   },
  /// );
  /// ```
  /// Then, something similar to this:
  /// ```dart
  /// firestore.collection('objects').where('search', arrayContains: [keyword]);
  /// ```
  /// OR
  /// ```dart
  /// firestore.collection('objects').where('search', arrayContainsAny: [keywords]);
  /// ```
  List<String> textSearchArray({int minLen = 3, String separator = ' '}) {
    return List<String>.from(searchIndex(minLen: minLen, separator: separator));
  }

  /// For [containsAll] elements
  ///
  /// Example:
  /// ```dart
  /// final collection = firestore.collection('objects').withConverter<Model>(
  ///   fromFirestore: (snapshot, options) => Model.fromJson(snapshot.data()!),
  ///   toFirestore: (model, options) {
  ///     return model.toJson()
  ///       ..['search'] = model.stringValue.textSearchMap();
  ///   },
  /// );
  /// ```
  /// Then, something similar to this:
  /// ```dart
  /// var Query<Model> query = MyBaseQuery();
  /// for (final t in keyword.split(' ')) {
  ///   query = query.where('search', arrayContains: t);
  /// }
  /// ```
  /// [Caution]!!! Always create nested objects for searching, otherwise you
  /// should manage your indexes. See:
  /// https://firebase.google.com/docs/firestore/solutions/index-map-field
  Map<String, bool> textSearchMap({int minLen = 3, String separator = ' '}) {
    final indexes = searchIndex(minLen: minLen, separator: separator);
    return {for (var e in indexes) e: true};
  }
}

///
/// Collection for querying based on [updatedAt] field, also essential if you
/// are caching with local database([Sqlite], [SharedPreferences], [Hive] etc...).
/// Store queried documents with [dateTime] field so when you query again.
/// A typical query would be:
/// ```dart
/// collection.where('timestamp', isGreaterThan: collectionObject.timestamp);
/// ```
/// Only newer documents will be queried by doing so.
/// [cacheHandler] callback will let you manipulate your local database
///
/// todo delete handler
extension FirestoreX on FirebaseFirestore {
  CollectionReference<R> cachedCollection<R>({
    required String path,
    required FirestoreFromJson<R> fromJson,
    required FirestoreToJson<R> toJson,
    required FirestoreCacheHandler<R> cacheHandler,
    String timestampKey = 'timestamp',
  }) {
    return collection(path).withConverter<R>(
      fromFirestore: (snapshot, _) {
        final data = snapshot.data()!;
        final value = fromJson(data);
        if (data[timestampKey] != null) {
          final ts = timestampConv.fromJson(data[timestampKey]);
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

extension DocumentReferenceEx<R> on DocumentReference<R> {
  Future<void> cachedDelete() async {
    // TODO
    throw UnimplementedError();
  }
}

typedef FirestoreCacheHandler<R> = void Function(
  String docId,
  R value,
  DateTime timestamp,
);
typedef FirestoreCacheDeleter<R> = void Function(
  String docId,
  DateTime timestamp,
);
typedef FirestoreFromJson<R> = R Function(Map<String, dynamic> json);
typedef FirestoreToJson<R> = Map<String, Object?> Function(R value);

extension DocumentSnapshotsEx<T> on List<DocumentSnapshot<T>> {
  Set<String> idSet() => {for (var doc in this) doc.id};

  Set<T> dataSet() => {for (var doc in this) doc.data()!};

  Map<String, T> idDataMap() => {for (var doc in this) doc.id: doc.data()!};

  DocumentSnapshot<T>? firstWhereId(String id) {
    for (var d in this) {
      if (d.id == id) return d;
    }
    return null;
  }
}

extension QuerySnapshotEx<T> on QuerySnapshot<T> {
  Set<String> idSet() => docs.idSet();

  Set<T> dataSet() => docs.dataSet();

  Map<String, T> idDataMap() => docs.idDataMap();

  DocumentSnapshot<T>? firstWhereId(String id) => docs.firstWhereId(id);
}
