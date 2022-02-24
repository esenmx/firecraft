part of firestorex;

class DateTimeTimestampConv implements JsonConverter<DateTime, dynamic> {
  const DateTimeTimestampConv();

  @override
  DateTime fromJson(dynamic value) {
    assert(value is Timestamp);
    return value.toDate();
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
    assert(value == null || value is Timestamp);
    return value?.toDate();
  }

  @override
  dynamic toJson(DateTime? value) {
    if (value == FireFlags.serverDateTime) {
      return FieldValue.serverTimestamp();
    }
    return value == null ? null : Timestamp.fromDate(value);
  }
}
