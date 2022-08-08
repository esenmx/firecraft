part of firestorex;

/// [O] is element type, [J] json type of element
class ArrayConv<O, J> implements JsonConverter<List<O>, Map<String, dynamic>> {
  const ArrayConv([this.conv]);

  final JsonConverter<O, J>? conv;

  @override
  List<O> fromJson(Map json) {
    final keys = json.keys.toList()..sort();
    return [
      for (var k in keys)
        if (conv == null) json[k] as O else conv!.fromJson(json[k] as J)
    ];
  }

  @override
  Map<String, J> toJson(List<O> object) {
    return {
      for (var i = 0; i < object.length; i++)
        i.toString(): conv == null ? object[i] as J : conv!.toJson(object[i])
    };
  }
}
