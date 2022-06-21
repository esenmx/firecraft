part of firestorex;

/// As of [freezed] 2.0, collections are unmodifiable by default.
/// To work with collections with effectively, you can use this extensions methods.
/// Methods with [copy] prefix means, it returns copy of itself(just like copyWith).
///
/// Using Unmodifiable collections is recommended for non-small projects.
/// Beware your application may suffer skipped frames with large data sets,
/// if so use mutable collections or [Isolate]
///
/// Every unmodifiable collection operation starts with [copy] prefix

extension UnmodifiableMapX<K, V> on Map<K, V> {
  Map<K, V> copyRemove(K id) {
    return {
      for (var k in keys)
        if (k != id) k: this[k]!
    };
  }

  Map<K, V> copySet(K k, V v) => {...this, k: v};

  Map<K, V> copyUpdate(
    K key,
    V Function(V value) updater, {
    V Function()? ifAbsent,
  }) {
    final value = this[key];
    final V newValue;
    if (value != null) {
      newValue = updater(value);
    } else {
      if (ifAbsent == null) {
        throw StateError('$key not found and ifAbsent is not provided');
      }
      newValue = ifAbsent.call();
    }
    return {...this, key: newValue};
  }

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
