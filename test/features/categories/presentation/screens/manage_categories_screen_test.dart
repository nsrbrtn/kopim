import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/domain/use_cases/save_category_use_case.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _StubSaveCategoryUseCase implements SaveCategoryUseCase {
  @override
  Future<void> call(Category category) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ManageCategoriesScreen', () {
    testWidgets('enables color confirmation button after selecting a swatch', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = ThemeData();

      await tester.pumpWidget(
        ProviderScope(
          // ignore: always_specify_types
          overrides: [
            manageCategoryTreeProvider.overrideWith(
              (Ref ref) => Stream<List<CategoryTreeNode>>.value(
                const <CategoryTreeNode>[],
              ),
            ),
            saveCategoryUseCaseProvider.overrideWith(
              (Ref ref) => _StubSaveCategoryUseCase(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: theme,
            home: const ManageCategoriesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(ManageCategoriesScreen),
      );
      final AppLocalizations strings = AppLocalizations.of(context)!;

      await tester.tap(find.byTooltip(strings.manageCategoriesAddAction));
      await tester.pumpAndSettle();

      final Finder openColorButton = find.widgetWithText(
        ListTile,
        strings.manageCategoriesColorLabel,
      );
      await tester.tap(openColorButton);
      await tester.pumpAndSettle();

      final Finder confirmFinder = find.widgetWithText(
        FilledButton,
        strings.dialogConfirm,
      );
      FilledButton confirmButton = tester.widget<FilledButton>(confirmFinder);
      expect(confirmButton.onPressed, isNull);

      await tester.tap(find.byKey(const ValueKey<String>('category-color-0')));
      await tester.pump();

      confirmButton = tester.widget<FilledButton>(confirmFinder);
      expect(confirmButton.onPressed, isNotNull);
    });

    testWidgets(
      'updates color preview after confirming a new swatch while editing',
      (WidgetTester tester) async {
        final CategoryTreeNode node = CategoryTreeNode(
          category: Category(
            id: 'c1',
            name: 'Food',
            type: 'expense',
            color: '#D6D58E',
            createdAt: DateTime.utc(2024),
            updatedAt: DateTime.utc(2024),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            // ignore: always_specify_types, the Override type is internal to riverpod
            overrides: [
              manageCategoryTreeProvider.overrideWith(
                (Ref ref) => Stream<List<CategoryTreeNode>>.value(
                  <CategoryTreeNode>[node],
                ),
              ),
              saveCategoryUseCaseProvider.overrideWith(
                (Ref ref) => _StubSaveCategoryUseCase(),
              ),
            ],
            // ignore: unnecessary_const
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              // ignore: unnecessary_const
              home: const ManageCategoriesScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final Finder dismissible = find.byKey(
          const ValueKey<String>('category:c1'),
        );
        await tester.ensureVisible(dismissible);
        await tester.fling(dismissible, const Offset(600, 0), 1000);
        await tester.pumpAndSettle();

        Container preview = tester.widget<Container>(
          find.byKey(const ValueKey<String>('category-color-preview')),
        );
        final BoxDecoration previewDecoration =
            preview.decoration! as BoxDecoration;
        expect(previewDecoration.color, equals(const Color(0xFFD6D58E)));

        final BuildContext context = tester.element(
          find.byType(ManageCategoriesScreen),
        );
        final AppLocalizations strings = AppLocalizations.of(context)!;

        await tester.tap(
          find.widgetWithText(ListTile, strings.manageCategoriesColorLabel),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey<String>('category-color-1')),
        );
        await tester.pump();

        await tester.tap(
          find.widgetWithText(FilledButton, strings.dialogConfirm),
        );
        await tester.pumpAndSettle();

        preview = tester.widget<Container>(
          find.byKey(const ValueKey<String>('category-color-preview')),
        );
        final BoxDecoration updatedDecoration =
            preview.decoration! as BoxDecoration;
        expect(updatedDecoration.color, equals(const Color(0xFFFC9683)));
      },
    );

    testWidgets('renders contrasting icon color for dark backgrounds', (
      WidgetTester tester,
    ) async {
      final CategoryTreeNode node = CategoryTreeNode(
        category: Category(
          id: 'dark',
          name: 'Dark',
          type: 'expense',
          color: '#042940',
          createdAt: DateTime.utc(2024),
          updatedAt: DateTime.utc(2024),
        ),
      );

      final ThemeData theme = ThemeData();

      await tester.pumpWidget(
        ProviderScope(
          // ignore: always_specify_types
          overrides: [
            manageCategoryTreeProvider.overrideWith(
              (Ref ref) => Stream<List<CategoryTreeNode>>.value(
                <CategoryTreeNode>[node],
              ),
            ),
            saveCategoryUseCaseProvider.overrideWith(
              (Ref ref) => _StubSaveCategoryUseCase(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: theme,
            home: const ManageCategoriesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Finder cardFinder = find.byKey(
        const ValueKey<String>('category-card:dark'),
      );
      final Finder iconFinder = find.descendant(
        of: cardFinder,
        matching: find.byIcon(Icons.category_outlined),
      );
      final Icon icon = tester.widget<Icon>(iconFinder.first);
      expect(icon.color, equals(Colors.white));
    });

    testWidgets('defaults to theme color when no background provided', (
      WidgetTester tester,
    ) async {
      final CategoryTreeNode node = CategoryTreeNode(
        category: Category(
          id: 'default',
          name: 'Default',
          type: 'expense',
          createdAt: DateTime.utc(2024),
          updatedAt: DateTime.utc(2024),
        ),
      );

      final ThemeData theme = ThemeData();

      await tester.pumpWidget(
        ProviderScope(
          // ignore: always_specify_types
          overrides: [
            manageCategoryTreeProvider.overrideWith(
              (Ref ref) => Stream<List<CategoryTreeNode>>.value(
                <CategoryTreeNode>[node],
              ),
            ),
            saveCategoryUseCaseProvider.overrideWith(
              (Ref ref) => _StubSaveCategoryUseCase(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: theme,
            home: const ManageCategoriesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Finder cardFinder = find.byKey(
        const ValueKey<String>('category-card:default'),
      );
      final Finder iconFinder = find.descendant(
        of: cardFinder,
        matching: find.byIcon(Icons.category_outlined),
      );
      final Icon icon = tester.widget<Icon>(iconFinder.first);
      expect(icon.color, equals(theme.colorScheme.onSurface));
    });
  });
}
