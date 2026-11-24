import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/screens/app_shell.dart';
import 'package:urfunfarming_mobile/widgets/svg_icon.dart';

/// The floating main bar: Home, Market, Forum, Explore.
///
/// Figma: Parts / Bottom nav / Main. The active tab gets a pale pill; when
/// [current] is a grower tool, no tab is highlighted.
class MainNavBar extends StatelessWidget {
  const MainNavBar({super.key, required this.current, required this.onSelect});

  final AppDestination current;
  final ValueChanged<AppDestination> onSelect;

  static const _tabs = [
    (AppDestination.home, 'Home', 'assets/icons/nav_home.svg'),
    (AppDestination.market, 'Market', 'assets/icons/nav_market.svg'),
    (AppDestination.forum, 'Forum', 'assets/icons/nav_forum.svg'),
    (AppDestination.explore, 'Explore', 'assets/icons/nav_explore.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.16),
            offset: const Offset(0, 8),
            blurRadius: 12,
          ),
        ],
      ),
      // The bar has a fixed height, so labels stop growing at 160% font size
      // (Flutter's own NavigationBar caps its labels the same way).
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.6,
        child: Row(
          children: [
            for (final (i, (destination, label, icon)) in _tabs.indexed) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: _NavTab(
                  label: label,
                  icon: icon,
                  selected: destination == current,
                  onTap: () => onSelect(destination),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.onSurface : colors.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? colors.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgIcon(icon, size: 22, color: foreground),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  height: 15 / 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
