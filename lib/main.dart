import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/marketplace/marketplace_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrFunFarming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      // Blank placeholder until the app shell exists. The marketplace entry
      // stays here so the teammate's module remains reachable; Stage 9
      // replaces it with the Market tab.
      home: const Scaffold(
        body: Center(child: MarketplaceButton()),
      ),
    );
  }
}
