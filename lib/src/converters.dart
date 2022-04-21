part of firestorex;

class DateTimeTimestampConv implements JsonConverter<DateTime, dynamic> {
  const DateTimeTimestampConv();

  @override
  DateTime fromJson(dynamic value) {
    assert(
      value is Timestamp,
      'A non-null Timestamp value assertion failed.'
      'If your field is nullable, you must use NullDateTimeTimestampConv',
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

class NullDateTimeTimestampConv implements JsonConverter<DateTime?, dynamic> {
  const NullDateTimeTimestampConv();

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
