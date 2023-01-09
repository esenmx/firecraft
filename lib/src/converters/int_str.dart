part of firecraft;

/// [CAUTION!] [This is only valid for IMMUTABLE integers].
/// Updates with [FieldValue.increment(value)] won't work.
///
/// It's inefficient to store small integers with Firestore because numbers are
/// always 64bit on [FirebaseFirestore]. Hence, storing very small numbers as
/// quantitative is storage size inefficient.
///
/// Converting small integers to [String] can save considerable space while
/// keeping the console usable(unlike [Blob] conversion, which uses [Base64]).

class IntStrConv implements JsonConverter<int, String> {
  const IntStrConv();

  @override
  int fromJson(String json) => int.parse(json);

  @override
  String toJson(int object) => object.toString();
}

class NullIntStrConv implements JsonConverter<int?, String?> {
  const NullIntStrConv();

  @override
  int? fromJson(String? json) => json == null ? null : int.parse(json);

  @override
  String? toJson(int? object) => object?.toString();
}
