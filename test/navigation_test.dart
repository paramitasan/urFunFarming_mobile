import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:urfunfarming_mobile/care/screens/care_page.dart';
import 'package:urfunfarming_mobile/explore/screens/explore_page.dart';
import 'package:urfunfarming_mobile/forum/screens/forum_page.dart';
import 'package:urfunfarming_mobile/gardens/screens/gardens_page.dart';
import 'package:urfunfarming_mobile/journal/screens/journal_page.dart';
import 'package:urfunfarming_mobile/main.dart';
import 'package:urfunfarming_mobile/marketplace/market_api.dart';
import 'package:urfunfarming_mobile/marketplace/market_screen.dart';
import 'package:urfunfarming_mobile/screens/app_shell.dart';
import 'package:urfunfarming_mobile/screens/home.dart';
import 'package:urfunfarming_mobile/theme.dart';
import 'package:urfunfarming_mobile/widgets/grower_tools_bar.dart';
import 'package:urfunfarming_mobile/widgets/main_nav_bar.dart';
import 'package:urfunfarming_mobile/widgets/profile_menu.dart';
import 'package:urfunfarming_mobile/widgets/svg_icon.dart';

/// A marketplace API that answers every request with an empty catalog.
MarketApi fakeMarketApi() => MarketApi(
    Uri.parse('https://example.test'),
    MockClient((_) async => http.Response(
        jsonEncode({'count': 0, 'page': 1, 'pages': 1, 'results': []}), 200,
        headers: {'content-type': 'application/json'})));

Widget shell({bool isGrower = true}) => MaterialApp(
    theme: appTheme(),
    home: AppShell(isGrower: isGrower, marketApi: fakeMarketApi()));

Finder mainTab(String label) =>
    find.descendant(of: find.byType(MainNavBar), matching: find.text(label));

Finder growerTool(String label) => find.descendant(
    of: find.byType(GrowerToolsBar), matching: find.text(label));

void main() {
  testWidgets('the app starts on Home', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.bySemanticsLabel('UrFunFarming'), findsOneWidget);
  });

  testWidgets('each main tab opens its page', (tester) async {
    await tester.pumpWidget(shell());

    for (final (label, page) in [
      ('Market', MarketScreen),
      ('Forum', ForumPage),
      ('Explore', ExplorePage),
      ('Home', HomePage),
    ]) {
      await tester.tap(mainTab(label));
      await tester.pumpAndSettle();
      expect(find.byType(page), findsOneWidget, reason: '$label tab');
    }
  });

  testWidgets('each grower tool opens its page', (tester) async {
    await tester.pumpWidget(shell());

    for (final (label, page) in [
      ('My gardens', GardensPage),
      ('Plant journal', JournalPage),
      ('Plant care', CarePage),
    ]) {
      await tester.tap(growerTool(label));
      await tester.pumpAndSettle();
      expect(find.byType(page), findsOneWidget, reason: '$label tool');
      expect(find.byType(HomePage), findsNothing);
    }
  });

  testWidgets('the grower bar is hidden for non-growers', (tester) async {
    await tester.pumpWidget(shell(isGrower: false));
    await tester.pumpAndSettle();

    expect(find.byType(GrowerToolsBar), findsNothing);
    expect(find.byType(MainNavBar), findsOneWidget);
    expect(find.text('Growing tools'), findsNothing);
    expect(find.text('Around the neighborhood'), findsOneWidget);
  });

  for (final scale in [1.0, 1.15, 1.3, 1.5, 2.0]) {
    testWidgets(
        'Home has no layout errors at ${(scale * 100).round()}% font size',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
          theme: appTheme(),
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!),
          home: AppShell(isGrower: true, marketApi: fakeMarketApi())));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  group('avatar menu', () {
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.byType(ProfileMenuButton));
      await tester.pumpAndSettle();
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Grower and buyer'), findsOneWidget);
    }

    testWidgets('opens and closes with the X button', (tester) async {
      await tester.pumpWidget(shell());
      await openMenu(tester);

      // While open, the avatar's spot shows the dark close (X) button.
      final closeIcon = find.byWidgetPredicate(
          (w) => w is SvgIcon && w.asset == 'assets/icons/menu_close.svg');
      expect(closeIcon, findsOneWidget);
      expect(tester.getCenter(closeIcon),
          tester.getCenter(find.byType(ProfileMenuButton)));

      await tester.tap(closeIcon);
      await tester.pumpAndSettle();
      expect(closeIcon, findsNothing);
      expect(find.text('Log out'), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('closes when the dimmed area is tapped', (tester) async {
      await tester.pumpWidget(shell());
      await openMenu(tester);

      await tester.tapAt(const Offset(20, 400));
      await tester.pumpAndSettle();
      expect(find.text('Log out'), findsNothing);
    });

    testWidgets('Profile opens the profile page and Back returns',
        (tester) async {
      await tester.pumpWidget(shell());
      await openMenu(tester);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Log out'), findsNothing);
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Log out closes the menu and explains it is not ready',
        (tester) async {
      await tester.pumpWidget(shell());
      await openMenu(tester);

      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('Log out'), findsNothing);
      expect(find.text('Log out is not available yet.'), findsOneWidget);
    });
  });
}
