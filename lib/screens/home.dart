import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/theme.dart';

/// The Home tab: greeting card (module tiles follow in a later stage).
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isGrower,
    this.userName = 'Muhamad Idris',
    this.today,
  });

  final bool isGrower;

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
      ],
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
