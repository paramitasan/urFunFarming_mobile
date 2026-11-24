// Kept for Flutter 3.24.5 support. Switch to material_ui when everyone is on 3.47+.
// ignore: deprecated_member_use
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
