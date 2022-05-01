part of firestorex;

/// todo doc
class FirestoreSearchFormatter extends TextInputFormatter {
  FirestoreSearchFormatter({
    this.separator = ' ',
    this.length = kFirestoreEqualityLimit,
  });

  final String separator;
  final int length;

  @override
  TextEditingValue formatEditUpdate(oldValue, newValue) {
    final newText = newValue.text;
    if (newText.startsWith(separator)) {
      return oldValue;
    }
    if (newText.endsWith('$separator$separator')) {
      return oldValue;
    }
    if (newText.endsWith(separator)) {
      if (newText._prepareForIndex(separator).length == length) {
        return oldValue;
      }
    }
    return newValue;
  }
}
