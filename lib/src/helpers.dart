part of firestorex;

extension DocumentSnapshotsHelper<T> on List<DocumentSnapshot<T>> {
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

extension QuerySnapshotHelper<T> on QuerySnapshot<T> {
  Set<String> idSet() => docs.idSet();

  Set<T> dataSet() => docs.dataSet();

  Map<String, T> idDataMap() => docs.idDataMap();

  DocumentSnapshot<T>? firstWhereId(String id) => docs.firstWhereWithId(id);
}

extension IterableHelper<E> on Iterable<E> {
  List<E>? get nullIfEmpty => isEmpty ? null : toList();
}

extension StringHelper on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
