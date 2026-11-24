import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/main.dart';

void main() {
  testWidgets('the app starts', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
