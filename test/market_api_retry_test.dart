import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:urfunfarming_mobile/marketplace/market_api.dart';

http.Response reply(Object body, int status) =>
    http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'});

const emptyPage = {'count': 0, 'page': 1, 'pages': 1, 'results': []};

void main() {
  test('an expired token is cleared and the request is retried once without it',
      () async {
    final sent = <String?>[];
    final api =
        MarketApi(Uri.parse('https://example.test'), MockClient((r) async {
      final auth = r.headers['Authorization'];
      sent.add('${r.method} ${r.url.path} ${auth ?? 'anonymous'}');
      return auth == null
          ? reply(emptyPage, 200)
          : reply({'detail': 'Invalid token.'}, 401);
    }), session: const MarketSession('expired', 'Ayu', true));

    final page = await api.catalog(filters: {'q': 'kale'});

    expect(page.count, 0);
    expect(api.session, isNull);
    expect(sent, [
      'GET /api/marketplace/listings/ Token expired',
      'GET /api/marketplace/listings/ anonymous',
    ]);
  });

  test('the retry keeps the query and body', () async {
    final requests = <http.Request>[];
    final api =
        MarketApi(Uri.parse('https://example.test'), MockClient((r) async {
      requests.add(r);
      return r.headers.containsKey('Authorization')
          ? reply({'detail': 'Invalid token.'}, 401)
          : reply({'detail': 'Authentication required.'}, 403);
    }), session: const MarketSession('expired', 'Ayu', true));

    await expectLater(api.save({'quantity': 2}, id: 'a'),
        throwsA(isA<MarketFailure>().having((e) => e.status, 'status', 403)));

    expect(requests, hasLength(2));
    expect(requests.last.method, 'PATCH');
    expect(requests.last.url, requests.first.url);
    expect(requests.last.body, requests.first.body);
    expect(requests.last.headers.containsKey('Authorization'), isFalse);
  });

  test('retries only once, and never without a saved token', () async {
    var calls = 0;
    final client = MockClient((r) async {
      calls++;
      return reply({'detail': 'Invalid token.'}, 401);
    });

    final withToken = MarketApi(Uri.parse('https://example.test'), client,
        session: const MarketSession('expired', 'Ayu', true));
    await expectLater(withToken.catalog(mine: true),
        throwsA(isA<MarketFailure>().having((e) => e.status, 'status', 401)));
    expect(calls, 2);
    expect(withToken.session, isNull);

    calls = 0;
    final anonymous = MarketApi(Uri.parse('https://example.test'), client);
    await expectLater(anonymous.catalog(), throwsA(isA<MarketFailure>()));
    expect(calls, 1);
  });
}
