part of '../firecraft.dart';

/// Because of type safety, sometimes it can be tedious to play between
/// [DateTime] and [FieldValue], [kFirecraftTimestamp] solves this issue.
///
/// [TimestampConv()]/[NullTimestampConv()] detects [kFirecraftTimestamp]
/// value and [FieldValue.serverTimestamp] is put into the [json] instead the
/// [kFirecraftTimestamp] value.
///
/// min possible [DateTime] value is chosen for least conflict.
final kFirecraftTimestamp = DateTime.utc(0);

/// Alias for [JsonKey(includeIfNull: true)]
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
const kIncludeIfNull = JsonKey(includeIfNull: true);

/// https://firebase.google.com/docs/firestore/query-data/queries#query_limitations
const int _kFirestoreEqualityLimit = 10;
