import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/screens/app_shell.dart';
import 'package:urfunfarming_mobile/widgets/svg_icon.dart';

/// Data for one home tile.
class HomeTileItem {
  const HomeTileItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.destination,
  });

  final String name;
  final String description;

  /// SVG asset path, e.g. 'assets/icons/tile_market.svg'.
  final String icon;

  /// Background of the rounded-square icon chip.
  final Color color;

  /// Where the shell goes when the tile is tapped.
  final AppDestination destination;
}

/// A white module card: coloured icon chip, title and a short description.
///
/// Figma: Parts / Home / Tile.
class HomeTile extends StatelessWidget {
  const HomeTile({super.key, required this.item, required this.onTap});

  final HomeTileItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgIcon(item.icon, size: 20, color: colors.onSurface),
              ),
              const Spacer(),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 17 / 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 15 / 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
