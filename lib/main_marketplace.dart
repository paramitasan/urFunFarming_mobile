// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'marketplace/market_api.dart';
import 'marketplace/market_bootstrap.dart';
import 'marketplace/market_screen.dart';

void main() => runApp(MarketplacePreview(api: createMarketApi()));

class MarketplacePreview extends StatelessWidget {
  const MarketplacePreview({super.key, required this.api});
  final MarketApi api;
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Harvest Marketplace',
      debugShowCheckedModeBanner: false,
      theme: harvestTheme(),
      home: MarketScreen(api: api));
}
