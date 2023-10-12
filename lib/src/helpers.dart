part of '../firecraft.dart';

extension QuerySnapshotX<D> on QuerySnapshot<D> {
  Map<String, D> asIdDataMap() {
    return {for (final d in docs) d.id: d.data()};
  }
}

extension IterableDocumentSnapshotX<D> on Iterable<DocumentSnapshot<D>> {
  Map<String, D?> asIdDataMap() {
    return {for (final d in this) d.id: d.data()};
  }
}

extension DateTimeFirecraft on DateTime {
  Timestamp get toTimestamp => Timestamp.fromDate(this);
}
