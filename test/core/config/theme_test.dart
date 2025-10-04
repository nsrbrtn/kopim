import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kopim/core/config/theme.dart';

void main() {
  group('Bottom navigation theming', () {
    testWidgets('uses onSurface colors in light theme', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = buildAppTheme(brightness: Brightness.light);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  label: 'Analytics',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(BottomNavigationBar),
      );
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      final Iterable<IconTheme> iconThemes = tester.widgetList<IconTheme>(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byType(IconTheme),
        ),
      );

      expect(
        iconThemes.any(
          (IconTheme theme) => theme.data.color == colorScheme.onSurface,
        ),
        isTrue,
      );
      expect(
        iconThemes.any(
          (IconTheme theme) => theme.data.color == colorScheme.onSurfaceVariant,
        ),
        isTrue,
      );
    });

    testWidgets('uses onSurface roles in dark theme', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = buildAppTheme(brightness: Brightness.dark);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  label: 'Analytics',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(BottomNavigationBar),
      );
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      final Iterable<IconTheme> iconThemes = tester.widgetList<IconTheme>(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byType(IconTheme),
        ),
      );

      expect(
        iconThemes.any(
          (IconTheme theme) => theme.data.color == colorScheme.onSurface,
        ),
        isTrue,
      );
      expect(
        iconThemes.any(
          (IconTheme theme) => theme.data.color == colorScheme.onSurfaceVariant,
        ),
        isTrue,
      );
    });
  });
}
