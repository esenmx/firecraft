import 'package:example/src/app.dart';
import 'package:example/src/model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final batch = FakeFirebaseFirestore().batch();
  await collection.get().then((value) async {
    value.docs.map((e) => batch.delete(e.reference));
  });
  for (var i = 0; i < 100; i++) {
    batch.set(collection.doc(), Model(i.toString()));
  }
  await batch.commit();

  runApp(const App());
}
