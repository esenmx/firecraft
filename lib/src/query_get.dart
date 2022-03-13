part of firestorex;

typedef DocumentsWidgetBuilder<T> = Widget Function(
    BuildContext context, DocumentSnapshot<T> doc);

class QueryGetListView<T extends Object?> extends StatefulWidget {
  QueryGetListView({
    Key? key,
    required this.query,
    required this.builder,
    this.scrollExtent = 200,
    this.loader,
    this.separator,
  })  : assert(query.parameters.containsKey('limit'),
            'limit parameter is required for pagination'),
        super(key: key);

  final Query<T> query;
  final DocumentsWidgetBuilder<T> builder;
  final double scrollExtent;
  final WidgetBuilder? loader;
  final IndexedWidgetBuilder? separator;

  @override
  _QueryGetListViewState<T> createState() => _QueryGetListViewState<T>();
}

class _QueryGetListViewState<T> extends State<QueryGetListView<T>> {
  final docs = <DocumentSnapshot<T>>[];
  late int limit;
  bool paginating = true;

  @override
  void initState() {
    limit = widget.query.parameters['limit'] as int;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant QueryGetListView<T> oldWidget) {
    if (widget.query != oldWidget.query) {
      docs.clear();
      setState(() {
        limit = widget.query.parameters['limit'] as int;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> paginate() async {
    if (!paginating && mounted) {
      setState(() {
        paginating = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!paginating) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - widget.scrollExtent) {
            paginate();
          }
        }
        return docs.length % limit == 0;
      },
      child: ListView.separated(
        itemCount: docs.length,
        separatorBuilder: (BuildContext context, int index) {
          return widget.separator?.call(context, index) ??
              const SizedBox.shrink();
        },
        itemBuilder: (BuildContext context, int index) {
          return widget.builder(context, docs.elementAt(index));
        },
      ),
    );
  }
}
