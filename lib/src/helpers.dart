part of firestorex;

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
/// todo docs
abstract class FireLimits {
  static const int kMaxEquality = 10;
  static const int kMaxContains = 10;
}

abstract class FireFlags {
  static final serverDateTime = DateTime(-1);
}
