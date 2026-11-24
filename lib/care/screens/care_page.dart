import 'package:flutter/material.dart';
import 'package:urfunfarming_mobile/widgets/empty_state.dart';

/// Plant care page, shown inside the app shell.
class CarePage extends StatelessWidget {
  const CarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(title: 'Plant care');
  }
}
