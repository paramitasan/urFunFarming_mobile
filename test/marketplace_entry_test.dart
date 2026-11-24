import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/marketplace/market_api.dart';
import 'package:urfunfarming_mobile/marketplace/market_screen.dart';
import 'package:urfunfarming_mobile/screens/app_shell.dart';
import 'package:urfunfarming_mobile/theme.dart';
import 'package:urfunfarming_mobile/widgets/grower_tools_bar.dart';
import 'package:urfunfarming_mobile/widgets/main_nav_bar.dart';

void main() {
  testWidgets(
      'the Market tab opens the marketplace with one app bar, above the bars, '
      'and Home leaves it', (tester) async {
    final paths = <String>[];
    final api =
        MarketApi(Uri.parse('https://example.test'), MockClient((r) async {
      paths.add(r.url.path);
      return http.Response(
          jsonEncode({'count': 0, 'page': 1, 'pages': 1, 'results': []}), 200,
          headers: {'content-type': 'application/json'});
    }));
    await tester.pumpWidget(MaterialApp(
        theme: appTheme(), home: AppShell(isGrower: true, marketApi: api)));
    Finder tab(String label) => find.descendant(
        of: find.byType(MainNavBar), matching: find.text(label));

    await tester.tap(tab('Market'));
    await tester.pumpAndSettle();
    expect(find.byType(MarketScreen), findsOneWidget);
    expect(find.text('Search harvests'), findsOneWidget);
    expect(paths, ['/api/marketplace/listings/']);
    expect(find.byType(AppBar), findsOneWidget);
    expect(tester.getBottomLeft(find.byType(MarketScreen)).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(GrowerToolsBar)).dy));

    await tester.tap(tab('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MarketScreen), findsNothing);
    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
