import 'package:material_ui/material_ui.dart';
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
