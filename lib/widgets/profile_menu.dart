import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/auth/screens/profile_page.dart';
import 'package:urfunfarming_mobile/widgets/svg_icon.dart';

/// The round avatar in the app bar. Tapping it dims the screen and opens the
/// profile menu under it; while the menu is open the avatar shows as a dark
/// close (X) button.
///
/// Figma: Profile menu (avatar tapped).
class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({
    super.key,
    required this.userName,
    required this.roles,
  });

  final String userName;

  /// e.g. "Grower and buyer".
  final String roles;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open profile menu',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _open(context),
        child: _Avatar(initials: initialsOf(userName)),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final box = context.findRenderObject()! as RenderBox;
    final avatar = box.localToGlobal(Offset.zero) & box.size;
    final colors = Theme.of(context).colorScheme;

    final choice = await showGeneralDialog<_MenuChoice>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close profile menu',
      barrierColor: colors.onSurface.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      pageBuilder: (dialogContext, _, __) => _ProfileMenuOverlay(
        avatar: avatar,
        userName: userName,
        roles: roles,
      ),
    );
    if (!context.mounted) return;

    switch (choice) {
      case _MenuChoice.profile:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
        );
      case _MenuChoice.logOut:
        // TODO: call /api/auth/logout/ and clear the saved token once login
        // exists.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Log out is not available yet.')),
          );
      case null:
        break; // Closed with X, the dimmed area or Back.
    }
  }
}

/// "Muhamad Idris" -> "MI".
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}

enum _MenuChoice { profile, logOut }

/// Everything drawn above the scrim: the close button where the avatar is,
/// and the menu card under it. Empty space lets taps reach the scrim.
class _ProfileMenuOverlay extends StatelessWidget {
  const _ProfileMenuOverlay({
    required this.avatar,
    required this.userName,
    required this.roles,
  });

  final Rect avatar;
  final String userName;
  final String roles;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final right = screenWidth - avatar.right;
    return Stack(
      children: [
        Positioned.fromRect(
          rect: avatar,
          child: const _CloseButton(),
        ),
        Positioned(
          top: avatar.bottom + 10,
          right: right,
          width: 256,
          child: _MenuCard(userName: userName, roles: roles),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Close profile menu',
      child: Material(
        color: colors.secondary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: SvgIcon(
              'assets/icons/menu_close.svg',
              size: 18,
              color: colors.onSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.userName, required this.roles});

  final String userName;
  final String roles;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.22),
            offset: const Offset(0, 12),
            blurRadius: 32,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _Avatar(initials: initialsOf(userName)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          roles,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _MenuItem(
              icon: 'assets/icons/menu_profile.svg',
              label: 'Profile',
              color: colors.onSurface,
              onTap: () => Navigator.of(context).pop(_MenuChoice.profile),
            ),
            const SizedBox(height: 2),
            _MenuItem(
              icon: 'assets/icons/menu_logout.svg',
              label: 'Log out',
              color: colors.error,
              onTap: () => Navigator.of(context).pop(_MenuChoice.logOut),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 16),
          child: Row(
            children: [
              SvgIcon(icon, size: 24, color: color),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  height: 22 / 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green circle with the user's initials.
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
