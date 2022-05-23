part of firestorex;

typedef QueryGetWidgetBuilder<T> = ScrollView Function(
    BuildContext context, List<QuerySnapshot<T>> snapshots, bool isPaginating);

typedef OnPagination<T> = void Function(
    Query<T> query, QuerySnapshot<T> snapshot);

typedef OnError<T> = void Function(
    Query<T> query, dynamic error, StackTrace stackTrace);

const _limitAssertionText = '''
Your query does not have `limit`, which is a must for a pagination.
Use `Query.limit(int limit)` for providing limit parameter.''';

const _paginationExtentAssertionText = '''
paginationExtent cannot be negative, this means user have to scroll beyond the body.
''';

/// Very abstract and yet extensible way to build paginated [Firestore] views
/// Requires [ScrollView] as a child and any of [ListView], [GridView],
/// [CustomScrollView] etc... is usable.
/// [T] is the type of your [CollectionReference<T>] or [QuerySnapshot<T>]
class QueryGetScrollView<T extends Object?> extends StatefulWidget {
  QueryGetScrollView({
    Key? key,
    required this.query,
    required this.builder,
    this.onPagination,
    this.onError,
    this.onQueryComplete,
    this.paginationExtent = kMinInteractiveDimension,
  })  : assert(paginationExtent >= 0, _paginationExtentAssertionText),
        assert(query.parameters.containsKey('limit'), _limitAssertionText),
        super(key: key);

  /// [query] requires [Query.limit()] execution.
  /// If [query] parameter is updated from upper level, [this] will restart
  final Query<T> query;

  /// All results from paginations provided as [List<QuerySnapshot<T>>].
  /// [isPaginating] stands for showing loading indicator anywhere on your
  /// builder, [setState] is not required for updating state.
  ///
  /// Example:
  /// ```dart
  /// builder: (context, snapshots, isPaginating) {
  ///         return ListView(
  ///           children: ListTile.divideTiles(
  ///             context: context,
  ///             tiles: [
  ///               for (var snapshot in snapshots)
  ///                 for (var doc in s.docs)
  ///                   ListTile(...),
  ///               if (isPaginating) const CircularProgressIndicator(),
  ///             ],
  ///           ).toList(),
  ///         );
  ///       }
  /// ```
  final QueryGetWidgetBuilder<T> builder;

  /// Called after every succesful pagination request
  /// Useful for caching results. Good news, [Query] implements [==] operator
  /// effectively. Even with case you don't use [cachedCollection] converter
  /// from this package, you can simply create [Map<Query<T>, QuerySnapshot<T>>]
  /// and put the values. Beware, this can result with stale results.
  final OnPagination<T>? onPagination;

  /// If a pagination proccess throws exception, this will be called instead
  /// [onPagination] callback
  /// [query] parameter is also exposed, so you'll easily know which pagination
  /// request causes the [error]
  final OnError<T>? onError;

  /// Callback triggered when all results are fetched.
  final VoidCallback? onQueryComplete;

  /// Makes possible the eager pagination. Default is set to
  /// [kMinInteractiveDimension], which means if you load 10 [ListTile] with
  /// default size, scrolling to the end of 9th [ListTile] will start the
  /// next pagination. Can provide seamless loading and better user experience.
  final double paginationExtent;

  @override
  _QueryGetScrollViewState<T> createState() => _QueryGetScrollViewState<T>();
}

class _QueryGetScrollViewState<T> extends State<QueryGetScrollView<T>> {
  final snapshots = <QuerySnapshot<T>>[];
  bool isPaginating = true;

  late final limit = widget.query.parameters['limit'] as int;

  DocumentSnapshot<T> get cursor => snapshots.last.docs.last;

  Future<void> paginate() async {
    if (!isPaginating) {
      /// for [initState()] guard
      setState(() {
        isPaginating = true;
      });
    }
    final query = snapshots.isEmpty
        ? widget.query
        : widget.query.startAfterDocument(cursor);
    try {
      await query.get().then(snapshots.add);
      widget.onPagination?.call(query, snapshots.last);
      if (snapshots.last.size % limit != 0) {
        widget.onQueryComplete?.call();
      }
    } catch (error, stackTrace) {
      widget.onError?.call(query, error, stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          isPaginating = false;
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
  void didUpdateWidget(covariant QueryGetScrollView<T> oldWidget) {
    if (widget.query != oldWidget.query) {
      setState(() {
        snapshots.clear();
        paginate();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      child: widget.builder(context, snapshots, isPaginating),
      onNotification: (notification) {
        final continues = snapshots.isEmpty || snapshots.last.size % limit == 0;
        if (!isPaginating && continues) {
          final effectivePixels =
              notification.metrics.maxScrollExtent - widget.paginationExtent;
          if (notification.metrics.pixels >= effectivePixels) {
            paginate();
          }
        }
        return continues;
      },
    );
  }
}
