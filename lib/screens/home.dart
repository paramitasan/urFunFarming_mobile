// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/screens/app_shell.dart';
import 'package:urfunfarming_mobile/theme.dart';
import 'package:urfunfarming_mobile/widgets/home_tile.dart';

const _growingTools = [
  HomeTileItem(
    name: 'My gardens',
    description: 'Beds and plants',
    icon: 'assets/icons/tile_gardens.svg',
    color: AppColors.gardens,
    destination: AppDestination.gardens,
  ),
  HomeTileItem(
    name: 'Plant journal',
    description: 'Logs and photos',
    icon: 'assets/icons/tile_journal.svg',
    color: AppColors.journal,
    destination: AppDestination.journal,
  ),
  HomeTileItem(
    name: 'Plant care',
    description: 'This week’s tasks',
    icon: 'assets/icons/tile_care.svg',
    color: AppColors.care,
    destination: AppDestination.care,
  ),
];

const _neighborhood = [
  HomeTileItem(
    name: 'Market',
    description: 'Fresh harvests',
    icon: 'assets/icons/tile_market.svg',
    color: AppColors.market,
    destination: AppDestination.market,
  ),
  HomeTileItem(
    name: 'Forum',
    description: 'Ask growers',
    icon: 'assets/icons/tile_forum.svg',
    color: AppColors.forum,
    destination: AppDestination.forum,
  ),
  HomeTileItem(
    name: 'Explore gardens',
    description: 'Public gardens',
    icon: 'assets/icons/tile_explore.svg',
    color: AppColors.explore,
    destination: AppDestination.explore,
  ),
];

/// The Home tab: greeting card and tiles that open every module.
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isGrower,
    required this.onOpen,
    this.userName = 'Muhamad Idris',
    this.today,
  });

  final bool isGrower;

  /// Called with the tile's destination; the shell switches to it.
  final ValueChanged<AppDestination> onOpen;

  // TODO: use the logged-in user's name once login exists.
  final String userName;

  /// Date shown on the card; defaults to now (injectable for tests).
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        _GreetingCard(
          name: userName,
          meta: '${_formatDate(today ?? DateTime.now())} · '
              '${isGrower ? 'Grower and buyer' : 'Buyer'}',
        ),
        if (isGrower)
          _TileSection(
            title: 'Growing tools',
            items: _growingTools,
            onOpen: onOpen,
          ),
        _TileSection(
          title: 'Around the neighborhood',
          items: _neighborhood,
          onOpen: onOpen,
        ),
      ],
    );
  }
}

/// A heading and a 3-column grid of tiles. The grid does not scroll by
/// itself; the page's ListView scrolls everything.
class _TileSection extends StatelessWidget {
  const _TileSection({
    required this.title,
    required this.items,
    required this.onOpen,
  });

  final String title;
  final List<HomeTileItem> items;
  final ValueChanged<AppDestination> onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              height: 22 / 17,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              // Tiles keep the design's 136 px height at any screen width, and
              // grow with the phone's font size: 72 px is padding, icon chip
              // and gap; 64 px is two title lines and two description lines.
              final tileWidth = (constraints.maxWidth - 2 * 10) / 3;
              final textHeight = MediaQuery.textScalerOf(context).scale(64);
              // Scaled text lines round up a little, hence the 4 px allowance.
              final tileHeight = textHeight > 64 ? 72 + textHeight + 4 : 136.0;
              return GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: tileWidth / tileHeight,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  for (final item in items)
                    HomeTile(
                      item: item,
                      onTap: () => onOpen(item.destination),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Figma: Parts / Home / Greeting card, without the skyline illustration.
// TODO: add the sun, cloud and skyline illustration from Figma.
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.name, required this.meta});

  final String name;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final headline = TextStyle(
      fontSize: 22,
      height: 27 / 22,
      fontWeight: FontWeight.w800,
      color: colors.onSurface,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.greetingTop, colors.secondaryContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good morning,', style: headline),
          Text('$name.', style: headline),
          const SizedBox(height: 6),
          Text(
            meta,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Fri, 20 Nov", as in the design.
String _formatDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';
