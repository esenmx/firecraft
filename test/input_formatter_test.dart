import 'package:firestorex/firestorex.dart';
import 'package:flutter_test/flutter_test.dart';

extension StringExtensions on String {
  TextEditingValue get value => TextEditingValue(text: this);
}

void main() async {
  testWidgets('FirestoreSearchFormatter', (WidgetTester tester) async {
    final formatter = FirestoreSearchFormatter();
    var oldValue = 'text'.value, newValue = 'text '.value;
    expect(formatter.formatEditUpdate(oldValue, newValue).text, newValue.text);

    oldValue = 'text '.value;
    newValue = 'text  '.value;
    expect(formatter.formatEditUpdate(oldValue, newValue).text, oldValue.text);

    oldValue = ''.value;
    newValue = ' '.value;
    expect(formatter.formatEditUpdate(oldValue, newValue).text, oldValue.text);

    final oldText = List.generate(10, (index) => 'text').join(' ') + 'text';
    final newText = oldText + ' ';
    oldValue = oldText.value;
    newValue = newText.value;
    expect(formatter.formatEditUpdate(oldValue, newValue).text, oldValue.text);
  });
}
