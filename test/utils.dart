import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

T findWidget<T extends Widget>() => find.byType(T).evaluate().first.widget as T;

T findWidgetAt<T extends Widget>(int index) =>
    find.byType(T).evaluate().elementAt(index).widget as T;
