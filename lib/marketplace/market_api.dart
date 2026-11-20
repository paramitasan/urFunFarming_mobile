import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;

class MarketFailure implements Exception {
  final String message;
  final int? status;
  const MarketFailure(this.message, [this.status]);
  @override
  String toString() => message;
}

class MarketSession {
  final String token, name;
  final bool grower;
  const MarketSession(this.token, this.name, this.grower);
  factory MarketSession.fromJson(Json j) => MarketSession(
        j['token'] as String,
        (j['display_name'] ?? j['username']) as String,
        j['is_grower'] == true,
      );
}

class Harvest {
  final Json fields;
  Harvest(this.fields);
  String value(String key) => fields[key]?.toString() ?? '';
  String get id => value('id');
  bool get managed => fields['can_manage'] == true;
  Map<String, dynamic>? get contact => fields['contact'] as Json?;
}

class MarketPage {
  final int count, page, pages;
  final List<Harvest> listings;
  MarketPage.fromJson(Json j)
      : count = j['count'],
        page = j['page'],
        pages = j['pages'],
        listings =
            (j['results'] as List).cast<Json>().map(Harvest.new).toList();
}

const categories = ['vegetables', 'fruits', 'herbs'];
const cities = ['Depok', 'Jakarta', 'Bogor', 'Bekasi', 'Tangerang'];
const units = ['g', 'kg', 'bunch', 'head', 'piece', 'pack'];
String dateText(DateTime d) => d.toIso8601String().split('T').first;
DateTime jakartaDate() {
  final t = DateTime.now().toUtc().add(const Duration(hours: 7));
  return DateTime.utc(t.year, t.month, t.day);
}

class MarketApi {
  final Uri origin;
  final http.Client client;
  MarketSession? session;
  MarketApi(this.origin, this.client, {this.session}) {
    final local =
        ['localhost', '127.0.0.1', '::1', '10.0.2.2'].contains(origin.host);
    if (origin.host.isEmpty ||
        origin.userInfo.isNotEmpty ||
        !(origin.scheme == 'https' || (local && origin.scheme == 'http'))) {
      throw ArgumentError(
          'Use an HTTPS backend origin, or HTTP on your local machine/emulator.');
    }
  }
  Future<Json> _call(String method, String path,
      {Map<String, String>? query, Json? body, bool auth = true}) async {
    final uri = origin.resolve(path).replace(queryParameters: query);
    final request = http.Request(method, uri)..followRedirects = false;
    final token = auth ? session?.token : null;
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Token $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    late http.Response response;
    try {
      response = await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const MarketFailure('The server took too long. Try again.');
    } on http.ClientException {
      throw const MarketFailure(
          'Cannot reach the marketplace. Check the connection and retry.');
    }
    final status = response.statusCode;
    if (status == 204) return {};
    if (status == 401 && token != null && token == session?.token) {
      session = null;
    }
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      decoded = null;
    }
    if (status < 200 || status >= 300) {
      if (decoded is Map) {
        final detail = decoded['detail'];
        if (detail is String) throw MarketFailure(detail, status);
        final errors = decoded['errors'] ?? decoded;
        if (errors is Map && errors.isNotEmpty) {
          final messages = errors.entries.map((e) {
            final v = e.value is List
                ? (e.value as List).join(' ')
                : e.value.toString();
            return e.key == '__all__' || e.key == 'non_field_errors'
                ? v
                : '${e.key}: $v';
          });
          throw MarketFailure(messages.join('\n'), status);
        }
      }
      throw MarketFailure(
          'Marketplace unavailable (HTTP $status). Check the Django API.',
          status);
    }
    if (decoded is! Json) {
      throw const MarketFailure(
          'The backend did not return the expected JSON.');
    }
    return decoded;
  }

  Future<void> login(String username, String password) async {
    session = MarketSession.fromJson(await _call('POST', '/api/auth/login/',
        auth: false,
        body: {'username': username.trim(), 'password': password}));
  }

  Future<void> logout() async {
    try {
      await _call('POST', '/api/auth/logout/');
    } finally {
      session = null;
    }
  }

  Future<MarketPage> catalog(
          {bool mine = false,
          int page = 1,
          Map<String, String> filters = const {}}) async =>
      MarketPage.fromJson(await _call(
          'GET', mine ? '/api/marketplace/mine/' : '/api/marketplace/listings/',
          query: {...filters, 'page': '$page'}));
  String _item(String id) =>
      '/api/marketplace/listings/${Uri.encodeComponent(id)}/';
  Future<Harvest> detail(String id) async =>
      Harvest(await _call('GET', _item(id)));
  Future<Harvest> save(Json fields, {String? id}) async => Harvest(await _call(
      id == null ? 'POST' : 'PATCH',
      id == null ? '/api/marketplace/listings/' : _item(id),
      body: fields));
  Future<void> remove(String id) async {
    await _call('DELETE', _item(id));
  }

  Future<Json> weather(String id, Map<String, String> filters) =>
      _call('GET', '${_item(id)}pickup-weather/', query: filters);
}
