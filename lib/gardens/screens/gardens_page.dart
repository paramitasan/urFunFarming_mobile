import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/widgets/empty_state.dart';

/// My gardens page, shown inside the app shell.
class GardensPage extends StatelessWidget {
  const GardensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(title: 'My gardens');
  }
}
