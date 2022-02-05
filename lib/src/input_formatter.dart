part of firestorex;

/// todo doc
class FirestoreSearchFormatter extends TextInputFormatter {
  FirestoreSearchFormatter({this.separator = ' '});

  final String separator;

  @override
  formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    if (newText.startsWith(separator)) {
      return oldValue;
    }
    if (newText.endsWith(separator + separator)) {
      return oldValue;
    }
    if (newText.endsWith(separator)) {
      if (newText._tune(separator).length == kFirestoreQueryEqualityLimit) {
        return oldValue;
      }
    }
    return newValue;
  }
}
