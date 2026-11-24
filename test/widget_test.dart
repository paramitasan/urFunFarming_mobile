import 'package:flutter_test/flutter_test.dart';
// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/main.dart';

void main() {
  testWidgets('the app starts', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
