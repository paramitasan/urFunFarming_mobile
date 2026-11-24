import 'package:flutter/foundation.dart';
// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:urfunfarming_mobile/config.dart';
import 'market_api.dart';

MarketApi createMarketApi() =>
    MarketApi(Uri.parse(marketOrigin()), http.Client());

/// The API origin for the marketplace: the shared [apiBaseUrl], except for
/// the local web preview (tool/demo_marketplace.sh), which serves the app
/// under /app/ next to the Django API on the same origin.
String marketOrigin({bool isWeb = kIsWeb, Uri? page}) {
  final location = page ?? Uri.base;
  final underApp =
      location.path == '/app' || location.path.startsWith('/app/');
  return isWeb && underApp ? location.origin : apiBaseUrl;
}

ThemeData harvestTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff316843)),
    scaffoldBackgroundColor: const Color(0xfffaf9f5),
    inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(), filled: true, fillColor: Colors.white));
