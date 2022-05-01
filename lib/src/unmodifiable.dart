part of firestorex;

///
typedef Document<T extends Object> = MapEntry<String, T>;

///
typedef DocumentMap<T extends Object> = Map<String, T>;

///
typedef SequenceMap<T extends Object> = Map<int, T>;

extension DataIterableEx<T extends Object> on Iterable<T> {
  SequenceMap<T> toSequenceMap() {
    return {for (int i = 0; i < length; i++) i: elementAt(i)};
  }
}
