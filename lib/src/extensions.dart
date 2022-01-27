extension FirestoreString on String {
  /// [minLen]: Minimum length of subStrings
  /// [sep]: Separators between strings
  Iterable<String> textSearchQueries({int minLen = 3, String sep = ' '}) sync* {
    assert(minLen > 0, 'minimum length must be positive');
    final subs = split(sep).where((e) {
      /// Eliminating dangling separators, possible double white-spaces etc.
      return e.isNotEmpty;
    }).map((e) {
      /// Eliminates conflicts conflicts like Turkish 'i-İ' and English i-I
      /// Reduces char-pool
      return e.toLowerCase();
    });
    for (final s in subs) {
      if (s.length > minLen) {
        final buffer = StringBuffer(s.substring(0, minLen - 1));
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

  Map<String, bool> textSearchJson({int minLen = 3, String sep = ' '}) {
    return {for (final str in textSearchQueries(minLen: minLen, sep: sep)) str: true};
  }
}
