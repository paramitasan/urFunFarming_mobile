import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'market_api.dart';

MarketApi createMarketApi() {
  const configured = String.fromEnvironment('API_BASE_URL');
  final origin = configured.isNotEmpty
      ? configured
      : kIsWeb
          ? Uri.base.origin
          : 'https://paramita-santoso-urfunfarming.pws.cs.ui.ac.id';
  return MarketApi(Uri.parse(origin), http.Client());
}

ThemeData harvestTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff316843)),
    scaffoldBackgroundColor: const Color(0xfffaf9f5),
    inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(), filled: true, fillColor: Colors.white));
