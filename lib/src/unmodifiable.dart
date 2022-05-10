part of firestorex;

/// As of [freezed] 2.0, collections are unmodifiable by default.
/// To work with collections with effectively, you can use this extensions methods.
/// Methods with [copy] prefix means, it returns copy of itself(just like copyWith).

extension UnmodifiableMapX<K, V> on Map<K, V> {
  Map<K, V> copyRemove(K id) {
    return {
      for (var k in keys)
        if (k != id) k: this[k]!
    };
  }

  Map<K, V> copySet(K k, V v) => {...this, k: v};

  Map<K, V> copySetBatch(Iterable<MapEntry<K, V>> entries) {
    return {...this, for (var e in entries) e.key: e.value};
  }
}

extension UnmodifiableListX<E> on List<E> {
  List<E> copyRemoveAt(int index) {
    return [
      for (int i = 0; i < length; i++)
        if (i != index) elementAt(i)
    ];
  }

  List<E> copyAdd(E e) => [...this, e];
}
