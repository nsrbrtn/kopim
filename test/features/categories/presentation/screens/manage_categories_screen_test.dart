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
  Future<Category> call(Category category) async => category;
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

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final Finder openColorButton = find.byTooltip('Choose color');
      expect(openColorButton, findsOneWidget);
      await tester.tap(openColorButton);
      await tester.pumpAndSettle();

      final Finder confirmFinder = find.widgetWithText(FilledButton, 'Confirm');
      FilledButton confirmButton = tester.widget<FilledButton>(confirmFinder);
      expect(confirmButton.onPressed, isNull);

      await tester.tap(find.byKey(const ValueKey<String>('category-color-0')));
      await tester.pump();

      confirmButton = tester.widget<FilledButton>(confirmFinder);
      expect(confirmButton.onPressed, isNotNull);
    });

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

      final CircleAvatar avatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(avatar.backgroundColor, equals(const Color(0xFF042940)));
      expect(avatar.foregroundColor, equals(Colors.white));
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

      final CircleAvatar avatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(
        avatar.foregroundColor,
        equals(theme.colorScheme.onSurfaceVariant),
      );
    });
  });
}
