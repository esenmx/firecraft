part of firestorex;

extension StringEx on String {
  /// An opinionated way to handle text searches in [Firestore]
  /// Instead bloating your model with index/query field, mutate your [toJson]
  /// method within converter via [textSearchArray] or [textSearchMap]
  @visibleForTesting
  Iterable<String> createIndexes(
      {int elementLength = 3, String separator = ' '}) sync* {
    assert(elementLength > 0, 'minimum length must be positive');

    for (var s in _textSearchTune(separator)) {
      if (s.length > elementLength) {
        var buffer = StringBuffer(s.substring(0, elementLength - 1));
        for (int i = elementLength - 1; i < s.length; i++) {
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
  Iterable<String> _textSearchTune(String separator) {
    return split(separator)
        .where((e) => e.isNotEmpty)
        .map((e) => e.toLowerCase());
  }

  /// For [contains] or [containsAny] text search
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
  List<String> textSearchArray({
    int elementLength = 3,
    String separator = ' ',
  }) {
    return List<String>.from(createIndexes(
      elementLength: elementLength,
      separator: separator,
    ));
  }

  /// For [containsAll] text search
  ///
  /// Example:
  /// ```dart
  /// final collection = firestore.collection('objects').withConverter<Model>(
  ///   fromFirestore: (snapshot, options) => Model.fromJson(snapshot.data()!),
  ///   toFirestore: (model, options) {
  ///     return model.toJson()
  ///       ..['search'] = model.text.textSearchMap();
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
  Map<String, bool> textSearchMap({
    int elementLength = 3,
    String separator = ' ',
  }) {
    final indexes = createIndexes(
      elementLength: elementLength,
      separator: separator,
    );
    return {for (var element in indexes) element: true};
  }
}

extension IterableDocumentSnapshotEx<T> on Iterable<DocumentSnapshot<T>> {
  Map<String, T> get toIdDataMap {
    return {for (var doc in this) doc.id: doc.data()!};
  }

  Iterable<MapEntry<String, T>> get toIdDataEntries sync* {
    for (final doc in this) {
      yield MapEntry(doc.id, doc.data()!);
    }
  }

  Iterable<T> get toData => map((e) => e.data()!);
}

extension CollectionReferenceEx<T> on CollectionReference<T> {
  Future<List<QuerySnapshot<T>>> batchDocByIds(
    Iterable<String> ids, [
    int subListLength = FireLimits.kMaxContains,
  ]) {
    return Future.wait(ids.to2D(subListLength).map((e) {
      return where(FieldPath.documentId, whereIn: e.toList()).get();
    }));
  }

  Iterable<Stream<QuerySnapshot<T>>> batchDocSnapshotsByIds(
    Iterable<String> ids, [
    int subListLength = FireLimits.kMaxContains,
  ]) {
    return ids.to2D(subListLength).map((e) {
      return where(FieldPath.documentId, whereIn: e.toList()).snapshots();
    });
  }
}

extension IterableQuerySnapshotEx<T> on Iterable<QuerySnapshot<T>> {
  Iterable<T> get toExpandedData => expand((e) => e.docs).map((e) => e.data()!);

  Map<String, T> get toIdDataMap {
    return {for (var value in expand((e) => e.docs)) value.id: value.data()!};
  }
}

extension QuerySnapshotEx<T> on QuerySnapshot<T> {
  Map<String, T> get toIdDataMap {
    return <String, T>{for (var doc in docs) doc.id: doc.data()!};
  }

  Iterable<T> get toData => docs.map((e) => e.data()!);
}
