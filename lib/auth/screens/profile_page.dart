import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/widgets/empty_state.dart';

/// Profile page, opened with Navigator.push on top of the app shell.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const EmptyState(title: 'Profile'),
    );
  }
}
