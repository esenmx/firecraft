part of firestorex;

class DateTimeConverter implements JsonConverter<DateTime, Timestamp> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Timestamp value) => value.toDate();

  @override
  Timestamp toJson(DateTime value) => Timestamp.fromDate(value);
}

class DateTimeNullConverter implements JsonConverter<DateTime?, Timestamp?> {
  const DateTimeNullConverter();

  @override
  DateTime? fromJson(Timestamp? value) => value?.toDate();

  @override
  Timestamp? toJson(DateTime? value) =>
      value == null ? null : Timestamp.fromDate(value);
}

class ServerTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const ServerTimestampConverter();

  @override
  DateTime? fromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  @override
  dynamic toJson(_) => FieldValue.serverTimestamp();
}

class ServerTimestampNullConverter
    implements JsonConverter<DateTime?, Object?> {
  const ServerTimestampNullConverter();

  @override
  DateTime? fromJson(Object? timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  @override
  Object? toJson(DateTime? date) =>
      date != null ? FieldValue.serverTimestamp() : null;
}
