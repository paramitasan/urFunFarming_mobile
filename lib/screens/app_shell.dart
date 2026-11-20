import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/care/screens/care_page.dart';
import 'package:urfunfarming_mobile/config.dart';
import 'package:urfunfarming_mobile/explore/screens/explore_page.dart';
import 'package:urfunfarming_mobile/forum/screens/forum_page.dart';
import 'package:urfunfarming_mobile/gardens/screens/gardens_page.dart';
import 'package:urfunfarming_mobile/journal/screens/journal_page.dart';
import 'package:urfunfarming_mobile/marketplace/market_api.dart';
import 'package:urfunfarming_mobile/marketplace/market_bootstrap.dart';
import 'package:urfunfarming_mobile/marketplace/market_screen.dart';
import 'package:urfunfarming_mobile/screens/home.dart';
import 'package:urfunfarming_mobile/widgets/grower_tools_bar.dart';
import 'package:urfunfarming_mobile/widgets/main_nav_bar.dart';
import 'package:urfunfarming_mobile/widgets/profile_menu.dart';

// TODO: replace with the logged-in user once login exists.
const sampleUserName = 'Muhamad Idris';

/// Every page the shell can show. The first four are main-bar tabs; the
/// last three are grower tools.
enum AppDestination { home, market, forum, explore, gardens, journal, care }

/// The app frame: app bar on top, the floating bottom bar(s), and the page
/// for the current destination in between.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.isGrower = previewAsGrower, this.marketApi});

  /// Growers also get the grower tools (gardens, journal, care).
  final bool isGrower;

  /// Marketplace API to use. When null the shell creates its own with
  /// createMarketApi() and closes it on dispose (tests pass a mock).
  final MarketApi? marketApi;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppDestination _current = AppDestination.home;

  // One marketplace API for the whole app, created the first time Market
  // opens, so the saved sign-in survives switching tabs.
  MarketApi? _ownedMarketApi;
  MarketApi get _marketApi =>
      widget.marketApi ?? (_ownedMarketApi ??= createMarketApi());

  @override
  void dispose() {
    _ownedMarketApi?.client.close();
    super.dispose();
  }

  void _select(AppDestination destination) {
    if (destination == _current) return;
    setState(() => _current = destination);
  }

  Widget _page() {
    return switch (_current) {
      AppDestination.home => HomePage(
          isGrower: widget.isGrower,
          onOpen: _select,
          userName: sampleUserName,
        ),
      AppDestination.market => MarketScreen(api: _marketApi),
      AppDestination.forum => const ForumPage(),
      AppDestination.explore => const ExplorePage(),
      AppDestination.gardens => const GardensPage(),
      AppDestination.journal => const JournalPage(),
      AppDestination.care => const CarePage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody stays false: the body ends above the bars, so the bars
      // never cover page content (the space below the body is the bars'
      // height, which the Scaffold works out from bottomNavigationBar).
      extendBody: false,
      // MarketScreen brings its own Scaffold and app bar (with Sign in /
      // Sign out), so the shell hides its app bar there to avoid two bars.
      appBar: _current == AppDestination.market
          ? null
          : AppBar(
              titleSpacing: 20,
              title: Image.asset(
                'assets/images/logo.png',
                height: 32,
                semanticLabel: 'UrFunFarming',
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ProfileMenuButton(
                    userName: sampleUserName,
                    roles: widget.isGrower ? 'Grower and buyer' : 'Buyer',
                  ),
                ),
              ],
            ),
      body: KeyedSubtree(key: ValueKey(_current), child: _page()),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isGrower) ...[
                GrowerToolsBar(current: _current, onSelect: _select),
                const SizedBox(height: 8),
              ],
              MainNavBar(current: _current, onSelect: _select),
            ],
          ),
        ),
      ),
    );
  }
}
