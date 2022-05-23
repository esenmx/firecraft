part of firestorex;

typedef QuerySnapshotWidgetBuilder<T> = Scrollable Function(
  BuildContext context,
  QuerySnapshot<T> snapshot,
);

class QueryListenBuilder extends StatefulWidget {
  const QueryListenBuilder({Key? key}) : super(key: key);

  @override
  _QueryListenBuilderState createState() => _QueryListenBuilderState();
}

class _QueryListenBuilderState extends State<QueryListenBuilder> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
