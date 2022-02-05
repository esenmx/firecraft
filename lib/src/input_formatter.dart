part of firestorex;

/// todo
class FirestoreSearchFormatter extends TextInputFormatter {
  FirestoreSearchFormatter({this.separator = ''});

  final String separator;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.endsWith('$separator$separator')) {
      return oldValue;
    }
    if (newValue.text.endsWith(separator)) {
      if (newValue.text._tune(separator).length ==
          FirebaseFirestore.instance.equalityLimitation) {
        return oldValue;
      }
    }
    return newValue;
  }
}
