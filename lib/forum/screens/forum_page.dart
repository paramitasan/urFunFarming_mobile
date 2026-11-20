import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/widgets/empty_state.dart';

/// Forum page, shown inside the app shell.
class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(title: 'Forum');
  }
}
