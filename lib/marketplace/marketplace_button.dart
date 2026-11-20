import 'package:material_ui/material_ui.dart';
import 'market_api.dart';
import 'market_bootstrap.dart';
import 'market_screen.dart';

/// A single entry for the existing home. A future shared menu can pass its
/// already-authenticated API instance; the button only closes clients it owns.
class MarketplaceButton extends StatefulWidget {
  const MarketplaceButton({super.key, this.api});
  final MarketApi? api;
  @override
  State<MarketplaceButton> createState() => _MarketplaceButtonState();
}

class _MarketplaceButtonState extends State<MarketplaceButton> {
  MarketApi? _owned;
  MarketApi get _api => widget.api ?? (_owned ??= createMarketApi());

  @override
  void dispose() {
    _owned?.client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        icon: const Icon(Icons.storefront_outlined),
        label: const Text('Harvest Marketplace'),
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/marketplace'),
            builder: (_) => MarketScreen(api: _api),
          ),
        ),
      );
}
