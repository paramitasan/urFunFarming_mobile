import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:urfunfarming_mobile/main_marketplace.dart';
import 'package:urfunfarming_mobile/marketplace/market_api.dart';

const root = 'https://market.example';
const sample = {
  'id': 'a',
  'title': 'Mint',
  'description': 'Balcony harvest',
  'category': 'herbs',
  'quantity_label': '5 bunches',
  'price_label': 'Free',
  'price_unit_label': '1 bunch',
  'status_label': 'Free to collect',
  'city': 'Depok',
  'area': 'Beji',
  'grower_name': 'Ayu',
  'can_manage': false
};
http.Response reply(Object data, [int status = 200]) =>
    http.Response(jsonEncode(data), status,
        headers: {'content-type': 'application/json'});

void main() {
  test('filters, credentials, updates and logout follow the Django contract',
      () async {
    var step = 0;
    final api = MarketApi(Uri.parse(root), MockClient((r) async {
      switch (step++) {
        case 0:
          expect(r.url.path, '/api/marketplace/listings/');
          expect(r.url.queryParameters, {'page': '2', 'q': 'mint & basil'});
          expect(r.headers['Authorization'], isNull);
          return reply({
            'count': 7,
            'page': 2,
            'pages': 2,
            'results': [sample]
          });
        case 1:
          expect(r.url.path, '/api/auth/login/');
          expect(jsonDecode(r.body),
              {'username': 'grower', 'password': 'test-only'});
          return reply({
            'token': 'test-token',
            'display_name': 'Ayu',
            'is_grower': true
          });
        case 2:
          expect(r.url.path, '/api/marketplace/listings/a/');
          expect(r.method, 'PATCH');
          expect(r.headers['Authorization'], 'Token test-token');
          expect(jsonDecode(r.body), {'is_available': false});
          return reply(sample);
        case 3:
          expect(r.url.path, '/api/auth/logout/');
          expect(r.method, 'POST');
          expect(r.headers['Authorization'], 'Token test-token');
          return http.Response('', 204);
        default:
          fail('Unexpected request');
      }
    }));
    final list = await api.catalog(page: 2, filters: {'q': 'mint & basil'});
    expect(list.listings.single.value('title'), 'Mint');
    expect(list.pages, 2);
    await api.login('grower', 'test-only');
    expect(api.session?.grower, true);
    await api.save({'is_available': false}, id: 'a');
    await api.logout();
    expect(api.session, isNull);
    expect(step, 4);
  });
  test('expired token is discarded; form mistakes are readable', () async {
    final api = MarketApi(
        Uri.parse(root),
        MockClient((r) async => r.method == 'GET'
            ? reply({'detail': 'Invalid token.'}, 401)
            : reply({
                'quantity': ['No stock']
              }, 400)),
        session: const MarketSession('expired', 'Ayu', true));
    await expectLater(api.catalog(mine: true),
        throwsA(isA<MarketFailure>().having((e) => e.status, 'status', 401)));
    expect(api.session, isNull);
    await expectLater(
        api.save({'quantity': 0}),
        throwsA(isA<MarketFailure>()
            .having((e) => e.message, 'message', 'quantity: No stock')));
  });
  testWidgets(
      'a guest can find an offer and sees a sign-in prompt instead of contacts',
      (tester) async {
    final api = MarketApi(
        Uri.parse(root),
        MockClient((r) async => r.url.path.endsWith('/a/')
            ? reply(sample)
            : reply({
                'count': 1,
                'page': 1,
                'pages': 1,
                'results': [sample]
              })));
    await tester.pumpWidget(MarketplacePreview(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Harvest Marketplace'), findsOneWidget);
    expect(find.text('Post a harvest'), findsNothing);
    await tester.tap(find.text('Mint'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to see contact details'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
  });
  testWidgets('retry replaces an API failure with an empty catalog',
      (tester) async {
    var attempts = 0;
    final api = MarketApi(
        Uri.parse(root),
        MockClient((r) async => ++attempts == 1
            ? reply({'detail': 'Temporarily offline'}, 503)
            : reply({'count': 0, 'page': 1, 'pages': 1, 'results': []})));
    await tester.pumpWidget(MarketplacePreview(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Temporarily offline'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No harvests found'), findsOneWidget);
  });
}
