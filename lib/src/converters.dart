part of firestorex;

const timestampConv = TimestampConv();

class TimestampConv implements JsonConverter<DateTime, Object?> {
  const TimestampConv();

  @override
  DateTime fromJson(Object? value) {
    assert(
      value is Timestamp,
      'a non-null `Timestamp` value assertion failed.'
      'if your field is nullable, you must use `NullTimestampConv`',
    );
    return (value as Timestamp).toDate();
  }

  @override
  Object? toJson(DateTime value) {
    if (value == kServerTimestampSentinel) {
      return FieldValue.serverTimestamp();
    }
    return Timestamp.fromDate(value);
  }
}

const nullTimestampConv = NullTimestampConv();

class NullTimestampConv implements JsonConverter<DateTime?, Object?> {
  const NullTimestampConv();

  @override
  DateTime? fromJson(Object? value) {
    assert(
      value == null || value is Timestamp,
      'a non `Timestamp` value returned',
    );
    return (value as Timestamp?)?.toDate();
  }

  @override
  Object? toJson(DateTime? value) {
    if (value == kServerTimestampSentinel) {
      return FieldValue.serverTimestamp();
    }
    return value == null ? null : Timestamp.fromDate(value);
  }
}
