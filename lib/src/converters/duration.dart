part of firecraft;

class DurationConv implements JsonConverter<Duration, int> {
  const DurationConv();

  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  @override
  int toJson(Duration object) => object.inMicroseconds;
}

class NullDurationConv implements JsonConverter<Duration?, int?> {
  const NullDurationConv();

  @override
  Duration? fromJson(int? json) {
    return json == null ? null : Duration(microseconds: json);
  }

  @override
  int? toJson(Duration? object) => object?.inMicroseconds;
}
