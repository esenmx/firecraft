part of firecraft;

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
    if (identical(value, kFirecraftTimestamp)) {
      return FieldValue.serverTimestamp();
    }
    return Timestamp.fromDate(value);
  }
}

class TimestampNConv implements JsonConverter<DateTime?, Object?> {
  const TimestampNConv();

  @override
  DateTime? fromJson(Object? value) {
    return (value as Timestamp?)?.toDate();
  }

  @override
  Object? toJson(DateTime? value) {
    if (identical(value, kFirecraftTimestamp)) {
      return FieldValue.serverTimestamp();
    }
    return value?.toTimestamp;
  }
}
