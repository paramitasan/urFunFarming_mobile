import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/widgets/empty_state.dart';

/// Explore gardens page, shown inside the app shell.
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(title: 'Explore gardens');
  }
}
