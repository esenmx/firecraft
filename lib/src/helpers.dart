part of firestorex;

extension QuerySnapshotX<D> on QuerySnapshot<D> {
  Map<String, D> asDataMap() {
    return {for (var d in docs) d.id: d.data()};
  }
}

extension IterableDocumentSnapshotX<D> on Iterable<DocumentSnapshot<D>> {
  Map<String, D?> asDataMap() {
    return {for (var d in this) d.id: d.data()};
  }
}

extension DateTimeFirestoreX on DateTime? {
  Timestamp? get toTimestamp => this == null ? null : Timestamp.fromDate(this!);
}
