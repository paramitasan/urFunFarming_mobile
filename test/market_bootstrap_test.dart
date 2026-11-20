import 'package:flutter_test/flutter_test.dart';
import 'package:urfunfarming_mobile/config.dart';
import 'package:urfunfarming_mobile/marketplace/market_bootstrap.dart';

void main() {
  test('mobile always uses the shared API address', () {
    expect(marketOrigin(isWeb: false), apiBaseUrl);
    expect(
      marketOrigin(isWeb: false, page: Uri.parse('http://127.0.0.1:8000/app/')),
      apiBaseUrl,
    );
  });

  test('web uses its own origin only when served under /app/', () {
    expect(
      marketOrigin(isWeb: true, page: Uri.parse('http://127.0.0.1:8000/app/')),
      'http://127.0.0.1:8000',
    );
    expect(
      marketOrigin(
        isWeb: true,
        page: Uri.parse('http://127.0.0.1:8000/app/index.html'),
      ),
      'http://127.0.0.1:8000',
    );
    expect(
      marketOrigin(isWeb: true, page: Uri.parse('http://localhost:53421/')),
      apiBaseUrl,
    );
    expect(
      marketOrigin(isWeb: true, page: Uri.parse('https://example.test/apps/')),
      apiBaseUrl,
    );
  });
}
