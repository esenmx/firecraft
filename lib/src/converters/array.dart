part of firestorex;

class ArrayConv<T> implements JsonConverter<List<T>, Map<String, T>> {
  const ArrayConv();

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

class NestedArrayConv<T>
    implements JsonConverter<List<List<T>>, Map<String, Map<String, T>>> {
  const NestedArrayConv();

  @override
  List<List<T>> fromJson(Map<String, Map<String, T>> json) {
    final array = <List<T>>[];
    for (var i = 0; i < json.length; i++) {
      assert(json.containsKey(i.toString()));
      final subArray = <T>[];
      array.add(subArray);
      for (var j = 0; j < json[i.toString()]!.length; j++) {
        assert(json[i.toString()]!.containsKey(j.toString()));
        subArray.add(json[i.toString()]![j.toString()] as T);
      }
    }
    return array;
  }

  @override
  Map<String, Map<String, T>> toJson(List<List<T>> object) {
    return {
      for (var i = 0; i < object.length; i++)
        i.toString(): {
          for (var j = 0; j < object[i].length; j++) j.toString(): object[i][j]
        }
    };
  }
}
