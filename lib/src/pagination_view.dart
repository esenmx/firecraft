import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestorePaginationView<T extends Object?> extends StatefulWidget {
  const FirestorePaginationView({
    Key? key,
    required this.colRef,
    required this.query,
    this.paginationExtent = 200,
  }) : super(key: key);

  final CollectionReference<T> colRef;
  final Query<T> query;
  final double paginationExtent;

  @override
  _FirestorePaginationViewState<T> createState() =>
      _FirestorePaginationViewState<T>();
}

class _FirestorePaginationViewState<T extends Object?>
    extends State<FirestorePaginationView> {
  final snapshotStreams = <Stream<QueryDocumentSnapshot<T>>>[];
  DocumentSnapshot<T>? cursor;

  @override
  void initState() {
    assert(
        widget.query.parameters.containsKey('limit'),
        'limit parameter is a must for pagination;'
        "if you don't need to limit your query, probably you won't need pagination");

    super.initState();
  }

  @override
  void didUpdateWidget(covariant FirestorePaginationView<T> oldWidget) {
    if (widget.query != oldWidget.query || widget.colRef != oldWidget.colRef) {
      // todo reset
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - widget.paginationExtent) {}
        return false;
      },
      child: ListView(),
    );
  }
}
