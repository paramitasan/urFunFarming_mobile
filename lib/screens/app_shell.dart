import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/care/screens/care_page.dart';
import 'package:urfunfarming_mobile/config.dart';
import 'package:urfunfarming_mobile/explore/screens/explore_page.dart';
import 'package:urfunfarming_mobile/forum/screens/forum_page.dart';
import 'package:urfunfarming_mobile/gardens/screens/gardens_page.dart';
import 'package:urfunfarming_mobile/journal/screens/journal_page.dart';
import 'package:urfunfarming_mobile/screens/home.dart';
import 'package:urfunfarming_mobile/widgets/empty_state.dart';
import 'package:urfunfarming_mobile/widgets/grower_tools_bar.dart';
import 'package:urfunfarming_mobile/widgets/main_nav_bar.dart';

/// Every page the shell can show. The first four are main-bar tabs; the
/// last three are grower tools.
enum AppDestination { home, market, forum, explore, gardens, journal, care }

/// The app frame: app bar on top, the floating bottom bar(s), and the page
/// for the current destination in between.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.isGrower = previewAsGrower});

  /// Growers also get the grower tools (gardens, journal, care).
  final bool isGrower;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppDestination _current = AppDestination.home;

  void _select(AppDestination destination) {
    if (destination == _current) return;
    setState(() => _current = destination);
  }

  Widget _page() {
    return switch (_current) {
      AppDestination.home => HomePage(isGrower: widget.isGrower),
      AppDestination.market => const EmptyState(title: 'Market'),
      AppDestination.forum => const ForumPage(),
      AppDestination.explore => const ExplorePage(),
      AppDestination.gardens => const GardensPage(),
      AppDestination.journal => const JournalPage(),
      AppDestination.care => const CarePage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      // extendBody stays false: the body ends above the bars, so the bars
      // never cover page content (the space below the body is the bars'
      // height, which the Scaffold works out from bottomNavigationBar).
      extendBody: false,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          'UrFunFarming',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: _Avatar(initials: 'MI'),
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

/// Round avatar with the user's initials. Does nothing yet.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 20,
      backgroundColor: colors.primary,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),
    );
  }
}
