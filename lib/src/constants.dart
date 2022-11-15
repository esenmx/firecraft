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
/// [kIncludeIfNull] is perfect fit for this case:
/// ```dart
/// @includeIfNull @nullTimestampConv DateTime? disabledAt,
/// ```
///
/// Favorably, only put null values into json if you need to query them,
/// otherwise it will increase both database and traffic size for no reason.
const kIncludeIfNull = JsonKey(includeIfNull: true);

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
const int kFirestoreEqualityLimit = 10;

/// Because of type safety, sometimes it can be tedious to play between
/// [DateTime] and [FieldValue], [kFirestoreTimestamp] solves this issue.
///
/// [TimestampConv()]/[NullTimestampConv()] detects [kFirestoreTimestamp]
/// value and [FieldValue.serverTimestamp] is put into the [json] instead the
/// [kFirestoreTimestamp] value.
///
/// min possible [DateTime] value is chosen for least conflict.
final kFirestoreTimestamp = DateTime.utc(-271821, 04, 20);
