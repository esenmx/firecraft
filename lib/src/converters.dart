part of firestorex;

const timestampConv = TimestampConv();

@visibleForTesting
class TimestampConv implements JsonConverter<DateTime, dynamic> {
  const TimestampConv();

  @override
  DateTime fromJson(dynamic value) {
    assert(
      value is Timestamp,
      'A non-null Timestamp value assertion failed.'
      'If your field is nullable, you must use NullTimestampConv',
    );
    return (value as Timestamp).toDate();
  }

  @override
  dynamic toJson(DateTime value) {
    if (value == FireFlags.serverDateTime) {
      return FieldValue.serverTimestamp();
    }
    return Timestamp.fromDate(value);
  }
}

const nullTimestampConv = NullTimestampConv();

@visibleForTesting
class NullTimestampConv implements JsonConverter<DateTime?, dynamic> {
  const NullTimestampConv();

  @override
  DateTime? fromJson(dynamic value) {
    assert(
      value == null || value is Timestamp,
      'A non Timestamp value returned',
    );
    return (value as Timestamp?)?.toDate();
  }

  @override
  dynamic toJson(DateTime? value) {
    if (value == FireFlags.serverDateTime) {
      return FieldValue.serverTimestamp();
    }
    return value == null ? null : Timestamp.fromDate(value);
  }
}
