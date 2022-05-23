import 'package:example/src/model.dart';
import 'package:firestorex/firestorex.dart';
import 'package:flutter/material.dart';

class QueryGetPage extends StatelessWidget {
  const QueryGetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Query Get Example')),
      body: QueryGetScrollView<Model>(
        query: collection.limit(10).orderBy('text'),
        onError: (query, error, stackTrace) {
          print('onError.query: ${query.parameters}');
          print('onError.error: $error');
          print('onError.stackTrace: $stackTrace');
        },
        onPagination: (query, snapshot) {
          final ids = snapshot.docs.map((e) => e.id);
          print('onPaginationEnd{${ids.join(', ')}}');
        },
        onQueryComplete: () {
          print('onQueryComplete()');
        },
        builder: (context, snapshots, isPaginating) {
          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                for (var s in snapshots)
                  for (var d in s.docs)
                    ListTile(title: Text(d.data().text), subtitle: Text(d.id)),
                if (isPaginating) const CircularProgressIndicator(),
              ],
            ).toList(),
          );
        },
      ),
    );
  }
}
