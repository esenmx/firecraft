part of firestorex;

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
abstract class FireLimits {
  static const int kMaxEquality = 10;
}

abstract class FireFlags {
  /// min [DateTime] possible for [FieldValue.serverTimestamp] sentinel
  static final serverDateTime = DateTime.utc(-271821, 04, 20);
}
