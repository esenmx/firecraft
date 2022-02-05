part of firestorex;

class FirestorePaginationView<T extends Object?> extends StatefulWidget {
  FirestorePaginationView({
    Key? key,
    required this.query,
    this.paginationExtent = 200,
  })  : assert(
          query.parameters.containsKey('limit'),
          "limit parameter is a must for pagination;\t"
          "if you don't need to limit your query, probably you won't need"
          "the pagination",
        ),
        super(key: key);

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
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FirestorePaginationView<T> oldWidget) {
    if (widget.query != oldWidget.query) {
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
