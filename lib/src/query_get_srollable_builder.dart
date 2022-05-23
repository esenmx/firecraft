part of firestorex;

typedef QueryGetWidgetBuilder<T> = ScrollView Function(
  BuildContext context,
  List<QuerySnapshot<T>> snapshots,
);
typedef OnPaginationEnd<T> = void Function(QuerySnapshot<T> snapshot);
typedef OnQueryUpdate<T> = void Function(
  Query<T> oldQuery,
  Query<T> newQuery,
  List<QuerySnapshot<T>> snapshots,
);

const _limitAssertionText = '''Your query does not execute `Query.limit(int)`, 
limit parameter is required for pagination''';

class QueryGetScrollViewBuilder<T extends Object?> extends StatefulWidget {
  QueryGetScrollViewBuilder({
    Key? key,
    required this.query,
    required this.builder,
    this.onPaginationStart,
    this.onPaginationEnd,
    this.onQueryUpdate,
    this.onQueryComplete,
    this.onError,
    this.scrollExtent = 200,
  })  : assert(query.parameters.containsKey('limit'), _limitAssertionText),
        super(key: key);

  final Query<T> query;
  final QueryGetWidgetBuilder<T> builder;
  final VoidCallback? onPaginationStart;
  final OnPaginationEnd<T>? onPaginationEnd;
  final OnQueryUpdate<T>? onQueryUpdate;
  final VoidCallback? onQueryComplete;
  final void Function(dynamic error, StackTrace stackTrace)? onError;
  final double scrollExtent;

  @override
  _QueryGetScrollViewBuilderState<T> createState() =>
      _QueryGetScrollViewBuilderState<T>();
}

class _QueryGetScrollViewBuilderState<T>
    extends State<QueryGetScrollViewBuilder<T>> {
  final snapshots = <QuerySnapshot<T>>[];
  bool paginating = true;

  late final limit = widget.query.parameters['limit'] as int;

  DocumentSnapshot<T> get cursor => snapshots.last.docs.last;

  Future<void> paginate() async {
    widget.onPaginationStart?.call();
    if (!paginating) {
      /// for [initState()] guard
      setState(() {
        paginating = true;
      });
    }
    try {
      if (snapshots.isEmpty) {
        await widget.query.get().then(snapshots.add);
      } else {
        await widget.query.startAfterDocument(cursor).get().then(snapshots.add);
      }
      widget.onPaginationEnd?.call(snapshots.last);
    } catch (error, stackTrace) {
      widget.onError?.call(error, stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          paginating = false;
        });
      }
    }
  }

  @override
  void initState() {
    paginate();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant QueryGetScrollViewBuilder<T> oldWidget) {
    if (widget.query != oldWidget.query) {
      setState(() {
        widget.onQueryUpdate?.call(oldWidget.query, widget.query, snapshots);
        snapshots.clear();
        paginate();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      child: widget.builder(context, snapshots),
      onNotification: (notification) {
        if (!paginating) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - widget.scrollExtent) {
            paginate();
          }
        }
        return snapshots.isEmpty || snapshots.last.docs.length % limit == 0;
      },
    );
  }
}
