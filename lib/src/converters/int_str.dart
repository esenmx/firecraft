part of firestorex;

/// It's inefficient to store small integers with Firestore because integers
/// are always 64bit.
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
