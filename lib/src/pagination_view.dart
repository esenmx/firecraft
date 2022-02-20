part of firestorex;

class FirestorePaginationView<T extends Object?> extends StatefulWidget {
  FirestorePaginationView({
    Key? key,
    required this.query,
    required this.builder,
    this.paginationExtent = 200,
    required this.loader,
  })  : assert(
          query.parameters.containsKey('limit'),
          "limit parameter is a must for pagination;\t"
          "if you don't need to limit your query, no pagination is required",
        ),
        super(key: key);

  final Query<T> query;
  final Widget Function(BuildContext context, Iterable<T> values) builder;
  final double paginationExtent;
  final Widget loader;

  @override
  _FirestorePaginationViewState<T> createState() =>
      _FirestorePaginationViewState<T>();
}

class _FirestorePaginationViewState<T>
    extends State<FirestorePaginationView<T>> {
  final snapshots = <Stream<QuerySnapshot<T>>>[];
  late int limit;
  // TODO

  @override
  void initState() {
    // TODO: implement initState
    limit = widget.query.parameters['limit'] as int;
    snapshots.add(widget.query.snapshots());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FirestorePaginationView<T> oldWidget) {
    // TODO: implement didUpdateWidget
    if (widget.query != oldWidget.query) {
      setState(() {
        snapshots.clear();
        limit = widget.query.parameters['limit'] as int;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
    return StreamBuilder<Iterable<T>>(
        stream: StreamZip(snapshots).map((query) => query.expand(
            (snapshot) => snapshot.docs.map((document) => document.data()))),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return widget.loader;
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent -
                      widget.paginationExtent) {}
              return snapshot.data!.length % limit == 0;
            },
            child: widget.builder(context, snapshot.data!),
          );
        });
  }
}
