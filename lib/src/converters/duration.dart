part of '../../firecraft.dart';

class DurationConv implements JsonConverter<Duration, int> {
  const DurationConv();

  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  @override
  int toJson(Duration object) => object.inMicroseconds;
}

class DurationNConv implements JsonConverter<Duration?, int?> {
  const DurationNConv();

  @override
  Duration? fromJson(int? json) {
    return json == null ? null : Duration(microseconds: json);
  }

  @override
  int? toJson(Duration? object) => object?.inMicroseconds;
}
