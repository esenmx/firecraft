part of '../firecraft.dart';

extension TextSearchBuilder on String {
  /// An opinionated way to handle text searches in [Firestore]
  ///
  /// [minKeywordLength] is size of [String]s that required
  /// for search [separator] is word separator (typically a white space)
  ///
  /// Instead bloating your model with and extra field, mutate your [toJson]
  /// method within converter via [textSearchArray] or [textSearchMap]
  /// Best practice example:
  /// ```dart
  /// final memberCollection = firestore.collection('member').withConverter<Member>(
  ///       fromFirestore: (snapshot, options) => Member.fromJson(snapshot.data()!),
  ///       toFirestore: (value, options) {
  ///         return value.toJson()..['search'] = value.displayName.textSearchMap();
  ///       },
  ///     );
  /// ```
  @visibleForTesting
  Iterable<String> strings({
    int minKeywordLength = 3,
    String separator = ' ',
  }) sync* {
    assert(minKeywordLength > 1, 'slice size must be greater than 1');
    final strings = _expand(separator);
    for (final s in strings) {
      if (s.length > minKeywordLength) {
        final buffer = StringBuffer(s.substring(0, minKeywordLength - 1));
        for (int i = minKeywordLength - 1; i < s.length; i++) {
          buffer.writeCharCode(s.codeUnitAt(i));
          yield buffer.toString();
        }
        buffer.clear();
      } else {
        yield s;
      }
    }
  }

  /// Eliminates empty split strings and lowercase all of them.
  /// [toLowerCase()] eliminates conflicts like Turkish İ-i, English I-i.
  Iterable<String> _expand(String separator) {
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
  List<String> textSearchArray({
    int minKeywordLength = 3,
    String separator = ' ',
  }) {
    return strings(
      minKeywordLength: minKeywordLength,
      separator: separator,
    ).toList();
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
  Map<String, bool> textSearchMap({
    int minKeywordLength = 3,
    String separator = ' ',
  }) {
    final index = strings(
      minKeywordLength: minKeywordLength,
      separator: separator,
    );
    return {for (final e in index) e: true};
  }
}

extension SearchQuery<T> on Query<T> {
  /// Use with [textSearchMap]. Generates the search query, typically by
  /// [TextField] input. Be careful of [_kFirestoreEqualityLimit].
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
