part of firestorex;

/// todo doc
class FirestoreSearchFormatter extends TextInputFormatter {
  FirestoreSearchFormatter({
    this.separator = ' ',
    this.length = FireLimits.kMaxEquality,
  });

  final String separator;
  final int length;

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
      if (newText._textSearchTune(separator).length == length) {
        return oldValue;
      }
    }
    return newValue;
  }
}
