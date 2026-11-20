import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/screens/app_shell.dart';
import 'package:urfunfarming_mobile/widgets/svg_icon.dart';

/// The floating grower tools bar above the main bar: My gardens, Plant
/// journal, Plant care.
///
/// Figma: Parts / Bottom nav / Grower tools. The active tool is a dark green
/// pill with light text.
class GrowerToolsBar extends StatelessWidget {
  const GrowerToolsBar({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final AppDestination current;
  final ValueChanged<AppDestination> onSelect;

  static const _tools = [
    (AppDestination.gardens, 'My gardens', 'assets/icons/tool_gardens.svg'),
    (AppDestination.journal, 'Plant journal', 'assets/icons/tool_journal.svg'),
    (AppDestination.care, 'Plant care', 'assets/icons/tool_care.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.10),
            offset: const Offset(0, 8),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          for (final (i, (destination, label, icon)) in _tools.indexed) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _ToolPill(
                label: label,
                icon: icon,
                selected: destination == current,
                onTap: () => onSelect(destination),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolPill extends StatelessWidget {
  const _ToolPill({
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
    final foreground = selected ? colors.onSecondary : colors.onSurface;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? colors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgIcon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
