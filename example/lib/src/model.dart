import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

final collection =
    FakeFirebaseFirestore().collection('test').withConverter<Model>(
          fromFirestore: (snapshot, options) {
            return Model(snapshot.data()!['text'] as String);
          },
          toFirestore: (object, options) => {'text': object.text},
        );

class Model {
  Model(this.text);

  final String text;

  @override
  String toString() => 'Model{text: $text}';
}
