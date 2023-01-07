part of firestorex;

extension QuerySnapshotX<D> on QuerySnapshot<D> {
  Map<String, D> asIdDataMap() {
    return {for (var d in docs) d.id: d.data()};
  }
}

extension IterableDocumentSnapshotX<D> on Iterable<DocumentSnapshot<D>> {
  Map<String, D?> asIdDataMap() {
    return {for (var d in this) d.id: d.data()};
  }
}

extension DateTimeFirestorEx on DateTime {
  Timestamp get toTimestamp => Timestamp.fromDate(this);
}
