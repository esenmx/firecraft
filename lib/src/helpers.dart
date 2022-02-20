part of firestorex;

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
/// todo docs
abstract class QueryLimitations {
  static const int kMaxQueryEquality = 10;
  static const int kMaxArrayContains = 10;
}

final serverTimestampFlag = DateTime(0);
