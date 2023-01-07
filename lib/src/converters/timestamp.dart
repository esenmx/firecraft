part of firestorex;

class TimestampConv implements JsonConverter<DateTime, Object?> {
  const TimestampConv();

  @override
  DateTime fromJson(Object? value) {
    if (value == null) {
      return DateTime.now();
    }
    return (value as Timestamp).toDate();
  }

  @override
  Object? toJson(DateTime value) {
    if (identical(value, kFirestorexTimestamp)) {
      return FieldValue.serverTimestamp();
    }
    return Timestamp.fromDate(value);
  }
}

class NullTimestampConv implements JsonConverter<DateTime?, Object?> {
  const NullTimestampConv();

  @override
  DateTime? fromJson(Object? value) {
    return (value as Timestamp?)?.toDate();
  }

  @override
  Object? toJson(DateTime? value) {
    if (identical(value, kFirestorexTimestamp)) {
      return FieldValue.serverTimestamp();
    }
    return value?.toTimestamp;
  }
}
