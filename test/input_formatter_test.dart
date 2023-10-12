import 'package:firecraft/firecraft.dart';
import 'package:flutter_test/flutter_test.dart';

extension StringExtensions on String {
  TextEditingValue get value => TextEditingValue(text: this);
}

void main() async {
  testWidgets('FirestoreSearchInputFormatter', (WidgetTester tester) async {
    final formatter = FirestoreSearchInputFormatter();

    /// Updates
    var oldValue = 'text'.value;
    var newValue = 'text '.value;
    expect(formatter.formatEditUpdate(oldValue, newValue).text, newValue.text);

    /// Won't update
    oldValue = 'text '.value;
    newValue = 'text  '.value;
    expect(formatter.formatEditUpdate(oldValue, newValue).text, oldValue.text);

    /// Won't update
    oldValue = ''.value;
    newValue = ' '.value;
    expect(formatter.formatEditUpdate(oldValue, newValue).text, oldValue.text);

    /// [FireLimits.kMaxEquality] check
    final oldText = '${List.generate(10, (index) => 'text').join(' ')}text';
    final newText = '$oldText ';
    oldValue = oldText.value;
    newValue = newText.value;
    expect(formatter.formatEditUpdate(oldValue, newValue).text, oldValue.text);
  });
}
