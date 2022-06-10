part of firestorex;

/// For reducing line width and speeding up the writing. Think about this example:
/// ```dart
/// @freezed
/// class Model with _$Model {
///   factory Model({
///     @JsonKey(includeIfNull: true) @nullTimestampConv DateTime? disabledAt,
///   }) = _Model;
///
///   factory Model.fromJson(Map<String, Object?> json) => _$ModelFromJson(json);
/// }
/// ```
/// Then you'll need something like this:
/// ```dart
/// query.('deletedAt', isNull: true);
/// query.('disabledAt', isNull: true);
/// ```
/// [includeIfNull] is perfect fit for this case:
/// ```dart
/// @includeIfNull @nullTimestampConv DateTime? disabledAt,
/// ```
///
/// Favourably, only put null values into json if you need to query them,
/// otherwise it will increase both database and traffic size for no reason.
const includeIfNull = JsonKey(includeIfNull: true);

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
const int kFirestoreEqualityLimit = 10;

/// Because of type safety, sometimes it can be tedious to play between
/// [DateTime] and [FieldValue], [kServerTimestampSentinel] solves this issue.
///
/// [timestampConv]/[nullTimestampConv] detects [kServerTimestampSentinel] and
/// [FieldValue.serverTimestamp] is put into [json] value instead field value.
///
/// min [DateTime] possible is chosen for least possible conflict.
final kServerTimestampSentinel = DateTime.utc(-271821, 04, 20);
