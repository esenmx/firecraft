part of firestorex;

extension TextSearchBuilder on String {
  /// An opinionated way to handle text searches in [Firestore]
  ///
  /// [slize] (aka. [slice] + [size]) stands for size of [String]s that required
  /// for search [separator] is word separator (typically a white space)
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
  Iterable<String> searchableStrings({
    int slize = 3,
    String separator = ' ',
  }) sync* {
    assert(slize > 1, 'slice size must be greater than 1');
    final strings = _warmup(separator);
    for (var s in strings) {
      if (s.length > slize) {
        var buffer = StringBuffer(s.substring(0, slize - 1));
        for (int i = slize - 1; i < s.length; i++) {
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
  Iterable<String> _warmup(String separator) {
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
  List<String> textSearchArray({int slize = 3, String separator = ' '}) {
    return searchableStrings(slize: slize, separator: separator).toList();
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
  Map<String, bool> textSearchMap({int slize = 3, String separator = ' '}) {
    final strings = searchableStrings(slize: slize, separator: separator);
    return {for (var e in strings) e: true};
  }
}

extension SearchQuery<T> on Query<T> {
  /// Use with [textSearchMap]. Generates the search query, typically by
  /// [TextField] input. Be careful of [kFirestoreEqualityLimit].
  Query<T> textSearchQuery(
    String text, {
    String prefix = 'search.',
    String separator = ' ',
  }) {
    final trimmedText = text.trim();
    assert(trimmedText.isNotEmpty);
    final words = trimmedText.split(separator).toSet();
    var query = this;
    for (var i = 0; i < words.length; i++) {
      query = query.where('$prefix${words.elementAt(i)}', isEqualTo: true);
    }
    return query;
  }
}
