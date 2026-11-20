import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:urfunfarming_mobile/marketplace/market_api.dart';
import 'package:urfunfarming_mobile/marketplace/marketplace_button.dart';

void main() {
  testWidgets(
      'the team home includes the marketplace, and its entry loads the catalog and returns',
      (tester) async {
    // TODO(stage 9): check that MyApp's Market tab opens MarketScreen.
    final paths = <String>[];
    final api =
        MarketApi(Uri.parse('https://example.test'), MockClient((r) async {
      paths.add(r.url.path);
      return http.Response(
          jsonEncode({'count': 0, 'page': 1, 'pages': 1, 'results': []}), 200,
          headers: {'content-type': 'application/json'});
    }));
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MarketplaceButton(api: api))));
    await tester.tap(find.text('Harvest Marketplace'));
    await tester.pumpAndSettle();
    expect(find.text('Search harvests'), findsOneWidget);
    expect(paths, ['/api/marketplace/listings/']);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MarketplaceButton), findsOneWidget);
    expect(find.text('Search harvests'), findsNothing);
  });
}
