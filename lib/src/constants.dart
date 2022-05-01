part of firestorex;

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
const int kMaxEqualityLimit = 10;

/// min [DateTime] possible chosen for [FieldValue.serverTimestamp] sentinel conversion
final kServerTimestampSentinel = DateTime.utc(-271821, 04, 20);
