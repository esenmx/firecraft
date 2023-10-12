part of '../../firecraft.dart';

/// [CAUTION!!!] [IntStrConv] is only sensible for IMMUTABLE integers.
/// Because [FieldValue.increment(value)] operations will be irrelevant.
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

class IntStrNConv implements JsonConverter<int?, String?> {
  const IntStrNConv();

  @override
  int? fromJson(String? json) => json == null ? null : int.parse(json);

  @override
  String? toJson(int? object) => object?.toString();
}
