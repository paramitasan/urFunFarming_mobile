import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/widgets/empty_state.dart';

/// Plant journal page, shown inside the app shell.
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(title: 'Plant journal');
  }
}
