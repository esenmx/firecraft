part of firestorex;

extension FirestoreStringExtensions on String {
  /// An opinionated way to handle text searches in [Firestore]
  /// Instead bloating your model with index/query field, mutate your [toJson]
  /// method within converter via [textSearchArray] or [textSearchMap]
  @visibleForTesting
  Iterable<String> createIndexes(
      {int elementLength = 3, String separator = ' '}) sync* {
    assert(elementLength > 0, 'minimum length must be positive');

    for (final s in _textSearchTune(separator)) {
      if (s.length > elementLength) {
        final buffer = StringBuffer(s.substring(0, elementLength - 1));
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
  Map<String, bool> textSearchMap({
    int elementLength = 3,
    String separator = ' ',
  }) {
    final indexes = createIndexes(
      elementLength: elementLength,
      separator: separator,
    );
    return {for (final element in indexes) element: true};
  }
}
