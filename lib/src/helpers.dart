part of firestorex;

extension DocumentSnapshotsX<T> on List<DocumentSnapshot<T>> {
  Set<String> idSet() => {for (var doc in this) doc.id};

  Set<T> dataSet() => {for (var doc in this) doc.data()!};

  Map<String, T> idDataMap() => {for (var doc in this) doc.id: doc.data()!};

  DocumentSnapshot<T>? firstWhereWithId(String id) {
    for (var d in this) {
      if (d.id == id) {
        return d;
      }
    }
    return null;
  }
}

extension QuerySnapshotX<T> on QuerySnapshot<T> {
  Set<String> idSet() => docs.idSet();

  Set<T> dataSet() => docs.dataSet();

  Map<String, T> idDataMap() => docs.idDataMap();

  DocumentSnapshot<T>? firstWhereId(String id) => docs.firstWhereWithId(id);
}

extension IterableX<E> on Iterable<E> {
  List<E>? get notEmptyOrNull => isEmpty ? null : toList();

  E? get singleOrNull => length == 1 ? single : null;
}
