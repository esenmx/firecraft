part of firestorex;

class NestedArrayConv<T> implements JsonConverter<List<T>, Map<String, T>> {
  const NestedArrayConv();

  @override
  List<T> fromJson(Map<String, T> json) {
    final array = <T>[];
    for (var i = 0; i < json.length; i++) {
      assert(json.containsKey(i.toString()));
      array.add(json[i.toString()] as T);
    }
    return array;
  }

  @override
  Map<String, T> toJson(List<T> object) {
    return {for (var i = 0; i < object.length; i++) i.toString(): object[i]};
  }
}
