part of firecraft;

/// Very abstract and yet extensible way to build paginated [Firestore] views
/// Requires [ScrollView] as a child and any of [ListView], [GridView],
/// [CustomScrollView] etc... is usable.
/// [T] is the type of your [CollectionReference<T>] or [QuerySnapshot<T>]
abstract class FirestorePaginationView<T> extends StatefulWidget {
  FirestorePaginationView({
    super.key,
    required this.query,
    this.onSnapshot,
    this.onError,
    this.onComplete,
    this.paginationExtent = kMinInteractiveDimension,
  })  : assert(paginationExtent >= 0, '''
`paginationExtent` cannot be negative, this means user have to scroll beyond the body.
'''),
        assert(query.parameters['limit'] != null, '''
your query does not have `limit`, which is a must for a pagination.
use `Query.limit(int limit)` for providing limit parameter.''');

  /// [query] requires [Query.limit()] execution.
  /// If [query] parameter is updated from upper level, [this] will restart.
  final Query<T> query;

  /// Called after every successful pagination request
  /// Useful for caching results. Good news, [Query] implements [==] operator
  /// effectively. Even with case you don't use [cachedCollection] converter
  /// from this package, you can simply create [Map<Query<T>, QuerySnapshot<T>>]
  /// and put the values.
  /// Beware, this can result with stale results.
  final Function(Query<T> query, QuerySnapshot<T> snapshot)? onSnapshot;

  /// If a pagination process throws exception, this will be called instead
  /// [onSnapshot] callback
  /// [query] parameter is also exposed, so you'll easily know which pagination
  /// request causes the [error]
  final Function(Query<T> query, Object? error, StackTrace stackTrace)? onError;

  /// Callback triggered when pagination is completed.
  final VoidCallback? onComplete;

  /// Makes possible the eager pagination. Default is set to
  /// [kMinInteractiveDimension], which means if you load 10 [ListTile] with
  /// default size, scrolling to the end of 9th [ListTile] will start the
  /// next pagination. Can provide seamless loading and better user experience.
  final double paginationExtent;

  late final limit = query.parameters['limit'] as int;
}

typedef FirestorePaginationViewBuilder<T> = Widget Function(
  BuildContext context,
  List<QueryDocumentSnapshot<T>> docs,
  bool isPaginating,
);

/// Cost effective way to pagination. Any update on [DocumentSnapshot] won't
/// be updated at UI. Choose this method if your [DocumentReference] won't
/// likely be to change. Otherwise prefer [FirestoreLivePaginationView]
/// Cost, only in case of last [QuerySnapshot].size == [0] +1 read added your
/// total docs.size. Also it's only 1 read if no result found.
class FirestoreStaticPaginationView<T> extends FirestorePaginationView<T> {
  FirestoreStaticPaginationView({
    super.key,
    required super.query,
    required this.builder,
    this.handler,
    super.onSnapshot,
    super.onError,
    super.onComplete,
    super.paginationExtent = kMinInteractiveDimension,
  });

  /// All results from pagination provided as [List<QuerySnapshot<T>>].
  /// [isPaginating] stands for showing loading indicator anywhere on your
  /// builder, [setState] is not required for updating state.
  /// ([snapshots.isEmpty && !isPaginating] == true) means no result.
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
  ///               if (isPaginating) Loader(),
  ///               if (snapshots.isEmpty && !isPaginating) NoResult(),
  ///             ],
  ///           ).toList(),
  ///         );
  ///       }
  /// ```
  final FirestorePaginationViewBuilder<T> builder;

  /// If not null, this method will be used instead default [Query.get()].
  /// Very simple example with [Provider/Riverpod]:
  /// ```dart
  /// final provider = StreamProvider.family<QuerySnapshot<T>, Query<T>>((ref, arg) {
  ///   return arg.snapshots();
  /// });
  /// ...
  /// handler: (query) {
  ///   return ref.watch(provider(query).future);
  /// }
  /// ```
  final Future<QuerySnapshot<T>> Function(Query<T> query)? handler;

  @override
  State<FirestoreStaticPaginationView<T>> createState() =>
      _FirestoreStaticPaginationViewState<T>();
}

class _FirestoreStaticPaginationViewState<T>
    extends State<FirestoreStaticPaginationView<T>> {
  QuerySnapshot<T>? lastSnapshot;
  final docs = <QueryDocumentSnapshot<T>>[];

  bool isPaginating = true;

  Future<void> paginate() async {
    if (!isPaginating) {
      /// for [initState()] guard
      setState(() {
        isPaginating = true;
      });
    }

    final query = lastSnapshot == null
        ? widget.query
        : widget.query.startAfterDocument(docs.last);

    try {
      if (widget.handler != null) {
        lastSnapshot = await widget.handler!(query);
      } else {
        lastSnapshot = await query.get();
      }
      docs.addAll(lastSnapshot!.docs);

      widget.onSnapshot?.call(query, lastSnapshot!);

      if (lastSnapshot!.size < widget.limit) {
        widget.onComplete?.call();
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
  void didUpdateWidget(covariant FirestoreStaticPaginationView<T> oldWidget) {
    if (widget.query != oldWidget.query) {
      docs.clear();
      lastSnapshot = null;
      paginate();
    }
    super.didUpdateWidget(oldWidget);
  }

  bool get continues {
    if (lastSnapshot == null) {
      return true;
    }
    return lastSnapshot!.size == widget.limit;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      child: widget.builder(context, docs, isPaginating),
      onNotification: (notification) {
        if (!isPaginating && continues) {
          final effectiveMaxScroll =
              notification.metrics.maxScrollExtent - widget.paginationExtent;
          if (notification.metrics.pixels >= effectiveMaxScroll) {
            paginate();
          }
        }
        return continues;
      },
    );
  }
}

/// Pagination with incrementing limit. Provides up to date data but more costly
/// than [FirestoreStaticPaginationView].
/// Pricing example with [limit] = 10:
/// For total result size of 35: 10 + 20 + 30 + 35 = 125
class FirestoreLivePaginationView<T> extends FirestorePaginationView<T> {
  FirestoreLivePaginationView({
    super.key,
    required super.query,
    required this.builder,
    this.handler,
    this.initialSnapshotHandler,
    super.onSnapshot,
    super.onError,
    super.onComplete,
    super.paginationExtent = kMinInteractiveDimension,
  });

  /// Provides [List<QueryDocumentSnapshot<T>>] based on latest [QuerySnapshot<T>].
  /// Results are always up to date.
  /// [isPaginating] stands for showing loading indicator anywhere on your
  /// builder, [setState] is not required for updating state.
  /// ([snapshots.isEmpty && !isPaginating] == true) means no result.
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
  ///               if (isPaginating) Loader(),
  ///               if (snapshots.isEmpty && !isPaginating) NoResult(),
  ///             ],
  ///           ).toList(),
  ///         );
  ///       }
  /// ```
  final FirestorePaginationViewBuilder<T> builder;
  final Stream<QuerySnapshot<T>> Function(Query<T> query)? handler;

  /// Handler for initial [Stream] values provided by [StreamProvider],
  /// [BehaviourSubject] etc.
  final QuerySnapshot<T>? Function(Query<T> query)? initialSnapshotHandler;

  @override
  State<FirestoreLivePaginationView<T>> createState() =>
      _FirestoreLivePaginationViewState<T>();
}

class _FirestoreLivePaginationViewState<T>
    extends State<FirestoreLivePaginationView<T>> {
  StreamSubscription<QuerySnapshot<T>>? subscription;
  var docs = <QueryDocumentSnapshot<T>>[];

  late int totalLimit = widget.limit;

  bool isPaginating = true;

  Future<void> paginate() async {
    if (!isPaginating) {
      /// guarding [initState()]
      setState(() {
        isPaginating = true;
        totalLimit += widget.limit;
      });
    }

    final query = widget.query.limit(totalLimit);

    if (widget.initialSnapshotHandler != null) {
      final snapshot = widget.initialSnapshotHandler!(query);
      if (snapshot?.docs != null) {
        docs = snapshot!.docs;
      }
      isPaginating = snapshot == null;
    }

    try {
      final Stream<QuerySnapshot<T>> stream;
      if (widget.handler != null) {
        stream = widget.handler!(query);
      } else {
        stream = query.snapshots();
      }

      subscription?.cancel();
      subscription = stream.listen((event) {
        widget.onSnapshot?.call(query, event);
        if (isPaginating && event.size < totalLimit) {
          widget.onComplete?.call();
        }
        if (mounted) {
          setState(() {
            isPaginating = false;
            docs = event.docs;
          });
        }
      }, onError: (error, stackTrace) {
        widget.onError?.call(query, error, stackTrace);
      });
    } catch (error, stackTrace) {
      widget.onError?.call(query, error, stackTrace);
    }
  }

  bool get continues {
    if (subscription == null) {
      return true;
    }
    return totalLimit <= docs.length;
  }

  @override
  void initState() {
    paginate();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FirestoreLivePaginationView<T> oldWidget) {
    if (widget.query != oldWidget.query) {
      subscription?.cancel();
      totalLimit = widget.limit;
      docs = [];
      paginate();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!isPaginating && continues) {
          final effectiveMaxScroll =
              notification.metrics.maxScrollExtent - widget.paginationExtent;
          if (notification.metrics.pixels >= effectiveMaxScroll) {
            paginate();
          }
        }
        return continues;
      },
      child: widget.builder(context, docs, isPaginating),
    );
  }
}
