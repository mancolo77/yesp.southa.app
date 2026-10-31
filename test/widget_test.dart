import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_/models/quiz_models.dart';
import 'package:app_/providers/loyalty_provider.dart';
import 'package:app_/screens/main_navigation_screen.dart';
import 'package:app_/services/quiz_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late QuizDataBundle bundle;

  setUpAll(() async {
    bundle = await QuizDataService.loadQuizData();
  });

  Widget createTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoyaltyProvider(initialBundle: bundle, autoInit: false),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('App smoke test: loads MainNavigationScreen without throwing exceptions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(child: const MainNavigationScreen()),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('Verify BottomNavigationBar has exactly 4 tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(child: const MainNavigationScreen()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final bottomNavBarFinder = find.byType(BottomNavigationBar);
    expect(bottomNavBarFinder, findsOneWidget);

    final BottomNavigationBar navBar =
        tester.widget<BottomNavigationBar>(bottomNavBarFinder);
    expect(navBar.items.length, 4);

    expect(find.text('Квизы'), findsOneWidget);
    expect(find.text('Дейли'), findsOneWidget);
    expect(find.text('Награды'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);
  });

  testWidgets('Verify NO Spin Wheel / Fortune Wheel exists in the widget tree',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(child: const MainNavigationScreen()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Колесо'), findsNothing);
    expect(find.textContaining('Wheel'), findsNothing);
    expect(find.textContaining('Фортуны'), findsNothing);
  });

  testWidgets(
      'Verify NO RenderFlex overflowed on small screen (320x568), standard screen (390x844), and tablet (800x1280)',
      (WidgetTester tester) async {
    final sizes = [
      const Size(320, 568), // Small phone (iPhone SE)
      const Size(390, 844), // Standard modern phone
      const Size(800, 1280), // Tablet
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        createTestWidget(child: const MainNavigationScreen()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Ensure no Flutter error was recorded during build
      expect(tester.takeException(), isNull);

      // Tap through all 4 tabs to verify layout responsiveness and no overflow
      for (int i = 0; i < 4; i++) {
        final navBar = find.byType(BottomNavigationBar);
        final tabItem = find.descendant(
          of: navBar,
          matching: find.byType(InkResponse).at(i),
        );
        await tester.tap(tabItem);
        await tester.pump(const Duration(milliseconds: 100));

        final exc = tester.takeException();
        if (exc != null) {
          debugPrint('>>> OVERFLOW AT SCREEN: $size, TAB INDEX: $i: $exc');
        }
        expect(exc, isNull);
      }
    }

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
