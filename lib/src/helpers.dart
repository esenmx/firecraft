part of firestorex;

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
/// todo docs
abstract class QueryLimitations {
  static const int kMaxEquality = 10;
  static const int kMaxArrayContains = 10;
}

abstract class FieldFlags {
  static final serverDateTime = DateTime(0);
}
