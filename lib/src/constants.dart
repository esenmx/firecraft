part of firestorex;

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
const int kFirestoreEqualityLimit = 10;

/// Because of type safety, sometimes it can be tedious to play between
/// [DateTime] and [FieldValue], [kServerTimestampSentinel] solves this issue.
///
/// [timestampConv]/[nullTimestampConv] detects [kServerTimestampSentinel] and
/// [FieldValue.serverTimestamp] is put into [json] value instead field value.
///
/// min [DateTime] possible is chosen for least conflict.
final kServerTimestampSentinel = DateTime.utc(-271821, 04, 20);
