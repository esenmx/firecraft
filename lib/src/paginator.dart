part of firestorex;

typedef OnSnapshot<T> = void Function(
    Query<T> query, QuerySnapshot<T> snapshot);

typedef OnError<T> = void Function(
    Query<T> query, Object? error, StackTrace stackTrace);

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
abstract class FirestorePaginator<T> extends StatefulWidget {
  FirestorePaginator({
    Key? key,
    required this.query,
    this.onSnapshot,
    this.onError,
    this.onComplete,
    this.paginationExtent = kMinInteractiveDimension,
  })  : assert(paginationExtent >= 0, _paginationExtentAssertionText),
        assert(query.parameters.containsKey('limit'), _limitAssertionText),
        super(key: key);

  /// [query] requires [Query.limit()] execution.
  /// If [query] parameter is updated from upper level, [this] will restart
  final Query<T> query;

  /// Called after every succesful pagination request
  /// Useful for caching results. Good news, [Query] implements [==] operator
  /// effectively. Even with case you don't use [cachedCollection] converter
  /// from this package, you can simply create [Map<Query<T>, QuerySnapshot<T>>]
  /// and put the values. Beware, this can result with stale results.
  final OnSnapshot<T>? onSnapshot;

  /// If a pagination proccess throws exception, this will be called instead
  /// [onSnapshot] callback
  /// [query] parameter is also exposed, so you'll easily know which pagination
  /// request causes the [error]
  final OnError<T>? onError;

  /// Callback triggered when all results are fetched.
  final VoidCallback? onComplete;

  /// Makes possible the eager pagination. Default is set to
  /// [kMinInteractiveDimension], which means if you load 10 [ListTile] with
  /// default size, scrolling to the end of 9th [ListTile] will start the
  /// next pagination. Can provide seamless loading and better user experience.
  final double paginationExtent;

  late final limit = query.parameters['limit'] as int;
}

typedef FirestorePaginatorBuilder<T> = ScrollView Function(
    BuildContext context, List<DocumentSnapshot<T>> docs, bool isPaginating);

typedef QueryHandler<T> = Future<QuerySnapshot<T>> Function(Query<T> query)?;

/// Cost effective way to pagination. Any update on [DocumentSnapshot] won't
/// be updated at UI. Choose this method if your [DocumentReference] won't
/// likely be to change. Otherwise prefer [ReactiveFirestorePaginator]
/// Cost, only in case of last [QuerySnapshot].size == [0] +1 read added your
/// total docs.size. Also it's only 1 read if no result found.
class StaticFirestorePaginator<T> extends FirestorePaginator<T> {
  StaticFirestorePaginator({
    Key? key,
    required Query<T> query,
    required this.builder,
    this.handler,
    OnSnapshot<T>? onNextPage,
    OnError<T>? onError,
    VoidCallback? onComplete,
    double paginationExtent = kMinInteractiveDimension,
  }) : super(
          key: key,
          query: query,
          onSnapshot: onNextPage,
          onError: onError,
          onComplete: onComplete,
          paginationExtent: paginationExtent,
        );

  /// All results from paginations provided as [List<QuerySnapshot<T>>].
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
  final FirestorePaginatorBuilder<T> builder;

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
  final QueryHandler<T> handler;

  @override
  _StaticFirestorePaginatorState<T> createState() =>
      _StaticFirestorePaginatorState<T>();
}

class _StaticFirestorePaginatorState<T>
    extends State<StaticFirestorePaginator<T>> {
  QuerySnapshot<T>? lastSnapshot;
  final docs = <DocumentSnapshot<T>>[];

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
  void didUpdateWidget(covariant StaticFirestorePaginator<T> oldWidget) {
    if (widget.query != oldWidget.query) {
      setState(() {
        docs.clear();
        lastSnapshot = null;
        paginate();
      });
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

/// Pagination with incrementing limit. Provies up to date data but more costly
/// than [StaticFirestorePaginator].
/// Pricing example with [limit] = 10:
/// For total result size of 35: 10 + 20 + 30 + 35 = 125
class ReactiveFirestorePaginator<T> extends FirestorePaginator<T> {
  ReactiveFirestorePaginator({
    Key? key,
    required Query<T> query,
    required this.builder,
    OnSnapshot<T>? onSnapshot,
    OnError<T>? onError,
    VoidCallback? onComplete,
    double paginationExtent = kMinInteractiveDimension,
  }) : super(
          key: key,
          query: query,
          onSnapshot: onSnapshot,
          onError: onError,
          onComplete: onComplete,
          paginationExtent: paginationExtent,
        );

  /// Provides [List<DocumentSnapshot<T>>] based on latest [QuerySnapshot<T>].
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
  final FirestorePaginatorBuilder<T> builder;

  @override
  _ReactiveFirestorePaginatorState<T> createState() =>
      _ReactiveFirestorePaginatorState<T>();
}

class _ReactiveFirestorePaginatorState<T>
    extends State<ReactiveFirestorePaginator<T>> {
  StreamSubscription<QuerySnapshot<T>>? subscription;
  final docs = <DocumentSnapshot<T>>[];

  late int effectiveLimit = widget.limit;

  bool isPaginating = true;

  Future<void> paginate() async {
    if (!isPaginating) {
      /// for [initState()] guard
      setState(() {
        isPaginating = true;
        effectiveLimit += widget.limit;
      });
    }

    final query = widget.query.limit(effectiveLimit);

    try {
      final stream = query.snapshots();

      subscription?.cancel();
      subscription = stream.listen((event) {
        widget.onSnapshot?.call(query, event);

        if (isPaginating && event.size < effectiveLimit) {
          widget.onComplete?.call();
        }

        if (mounted) {
          setState(() {
            isPaginating = false;
            docs.clear();
            docs.addAll(event.docs);
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
    return effectiveLimit <= docs.length;
  }

  @override
  void initState() {
    paginate();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ReactiveFirestorePaginator<T> oldWidget) {
    if (widget.query != oldWidget.query) {
      subscription?.cancel();
      setState(() {
        subscription = null;
        effectiveLimit = widget.limit;
        docs.clear();
      });
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
