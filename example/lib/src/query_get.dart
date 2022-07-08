import 'package:example/src/model.dart';
import 'package:firestorex/firestorex.dart';
import 'package:flutter/material.dart';

class QueryGetPage extends StatelessWidget {
  const QueryGetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Query Get Example')),
      body: FirestoreStaticPaginationView<Model>(
        query: collection.limit(10).orderBy('text'),
        onError: (query, error, stackTrace) {
          print('onError.query: ${query.parameters}');
          print('onError.error: $error');
          print('onError.stackTrace: $stackTrace');
        },
        onSnapshot: (query, snapshot) {
          final ids = snapshot.docs.map((e) => e.id);
          print('onPaginationEnd{${ids.join(', ')}}');
        },
        onComplete: () {
          print('onQueryComplete()');
        },
        builder: (context, docs, isPaginating) {
          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                for (var d in docs)
                  ListTile(title: Text(d.data().text), subtitle: Text(d.id)),
                if (isPaginating) const CircularProgressIndicator(),
                if (docs.isEmpty && !isPaginating) const FlutterLogo()
              ],
            ).toList(),
          );
        },
      ),
    );
  }
}
