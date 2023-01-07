part of firestorex;

/// As of [freezed] 2.0, collections are unmodifiable by default.
/// To work with collections effectively, you can use this extensions methods.
/// Methods with [copy] prefix means, returns a new shallow copy; hence,
/// it does not mutate the caller object.
///
/// Using Unmodifiable collections is recommended for non-trivial projects.
/// Beware your application may suffer skipped frames with large data sets.
/// Otherwise, consider using mutable collections.
///
/// Every unmodifiable collection operation starts with [copy] prefix.

extension MapX<K, V> on Map<K, V> {
  Map<K, V> copyRemove(K id) {
    return {
      for (var k in keys)
        if (k != id) k: this[k] as V
    };
  }

  Map<K, V> copySet(K k, V v) => {...this, k: v};

  Map<K, V> copyUpdate(
    K key,
    V Function(V value) update, {
    V Function()? ifAbsent,
  }) {
    final value = this[key];
    final V newValue;
    if (value != null) {
      newValue = update(value);
    } else {
      if (ifAbsent == null) {
        throw ArgumentError('`$key` not found and ifAbsent is `null`');
      }
      newValue = ifAbsent.call();
    }
    return {...this, key: newValue};
  }

  Map<K, V> copyAddEntries(Iterable<MapEntry<K, V>> entries) {
    return {
      ...this,
      for (var e in entries) e.key: e.value,
    };
  }
}

extension ListX<E> on List<E> {
  List<E> copyAdd(E value) => [...this, value];

  List<E> copyRemove(E value) {
    return [
      for (var e in this)
        if (e != value) e
    ];
  }

  List<E> copyRemoveAt(int index) {
    return [
      for (int i = 0; i < length; i++)
        if (i != index) elementAt(i)
    ];
  }

  List<E> copyWhere(bool Function(E element) test) {
    return [
      for (var e in this)
        if (test(e)) e
    ];
  }
}
