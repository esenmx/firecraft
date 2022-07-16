part of firestorex;

class ArrayConv<T> implements JsonConverter<List<T>, Map<String, dynamic>> {
  const ArrayConv();

  @override
  List<T> fromJson(Map<String, dynamic> json) {
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
    implements JsonConverter<List<List<T>>, Map<String, dynamic>> {
  const NestedArrayConv();

  @override
  List<List<T>> fromJson(Map<String, dynamic> json) {
    final array = <List<T>>[];
    for (var i = 0; i < json.length; i++) {
      assert(json.containsKey(i.toString()));
      final subArray = <T>[];
      array.add(subArray);
      final subJson = json[i.toString()] as Map;
      for (var j = 0; j < subJson.length; j++) {
        assert(subJson.containsKey(j.toString()));
        subArray.add(subJson[j.toString()] as T);
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
