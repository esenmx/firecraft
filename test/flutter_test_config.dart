import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

final instance = FakeFirebaseFirestore();

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await testMain();
}
