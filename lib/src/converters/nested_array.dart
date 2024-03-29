part of '../../firecraft.dart';

/// [O] is element type, [J] json type of element
class NestedArrayConv<O, J>
    implements JsonConverter<List<O>, Map<String, dynamic>> {
  const NestedArrayConv([this.conv]);

  final JsonConverter<O, J>? conv;

  @override
  List<O> fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return [];
    }
    final keys = json.keys.map((e) => int.parse(e)).toList()..sort();
    return [
      for (final key in keys)
        if (conv == null)
          json[key.toString()] as O
        else
          conv!.fromJson(json[key.toString()] as J),
    ];
  }

  @override
  Map<String, J> toJson(List<O> object) {
    if (object.isEmpty) {
      return {};
    }
    return {
      for (var i = 0; i < object.length; i++)
        i.toString(): conv == null ? object[i] as J : conv!.toJson(object[i]),
    };
  }
}
