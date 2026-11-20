import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/widgets/empty_state.dart';

/// Log in page, opened with Navigator.push on top of the app shell.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: const EmptyState(title: 'Log in'),
    );
  }
}
