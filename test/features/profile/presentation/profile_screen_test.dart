import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/core/di/injectors.dart';
import 'package:kopim/features/categories/domain/entities/category_tree_node.dart';
import 'package:kopim/features/categories/presentation/controllers/categories_list_controller.dart';
import 'package:kopim/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:kopim/features/profile/domain/entities/auth_user.dart';
import 'package:kopim/features/profile/domain/entities/profile.dart';
import 'package:kopim/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kopim/features/profile/presentation/controllers/auth_controller.dart';
import 'package:kopim/features/profile/presentation/controllers/profile_controller.dart';
import 'package:kopim/features/profile/presentation/screens/profile_screen.dart';
import 'package:kopim/l10n/app_localizations.dart';

class _StubUpdateProfileUseCase implements UpdateProfileUseCase {
  @override
  Future<Profile> call(Profile profile) async => profile;
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  FutureOr<AuthUser?> build() => _user;
}

class _SignOutSpyAuthController extends AuthController {
  _SignOutSpyAuthController(this._user, this._onSignOut);

  final AuthUser? _user;
  final VoidCallback _onSignOut;

  @override
  FutureOr<AuthUser?> build() => _user;

  @override
  Future<void> signOut() async {
    _onSignOut();
    state = const AsyncValue<AuthUser?>.data(null);
  }
}

class _FakeProfileController extends ProfileController {
  _FakeProfileController(this._profile);

  final Profile? _profile;

  @override
  FutureOr<Profile?> build(String uid) => _profile;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const AuthUser signedInUser = AuthUser(
    uid: 'user-42',
    email: 'user@example.com',
    isAnonymous: false,
    emailVerified: true,
  );

  final Profile hydratedProfile = Profile(
    uid: signedInUser.uid,
    name: 'Alice',
    currency: ProfileCurrency.eur,
    locale: 'en',
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  testWidgets('renders hydrated profile form with initial values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(
            () => _FakeAuthController(signedInUser),
          ),
          profileControllerProvider(
            signedInUser.uid,
          ).overrideWith(() => _FakeProfileController(hydratedProfile)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    final TextFormField nameField = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );
    expect(nameField.initialValue, equals('Alice'));

    expect(find.text('EUR'), findsWidgets);
    expect(find.text('EN'), findsWidgets);
    expect(find.text('Manage categories'), findsOneWidget);
  });

  testWidgets('shows sign-in prompt when user is absent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(() => _FakeAuthController(null)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Please sign in to manage your profile.'), findsOneWidget);
  });

  testWidgets('tapping manage categories button opens categories screen', (
    WidgetTester tester,
  ) async {
    final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];
    final NavigatorObserver observer = _RecordingNavigatorObserver(
      pushedRoutes,
    );

    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(
            () => _FakeAuthController(signedInUser),
          ),
          profileControllerProvider(
            signedInUser.uid,
          ).overrideWith(() => _FakeProfileController(hydratedProfile)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
          routes: <String, WidgetBuilder>{
            ManageCategoriesScreen.routeName: (_) =>
                const ManageCategoriesScreen(),
          },
          navigatorObservers: <NavigatorObserver>[observer],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manage categories'));
    await tester.pumpAndSettle();

    expect(
      pushedRoutes.map((Route<dynamic> route) => route.settings.name),
      contains(ManageCategoriesScreen.routeName),
    );
    expect(find.byType(ManageCategoriesScreen), findsOneWidget);
  });

  testWidgets('sign out button triggers auth controller sign out', (
    WidgetTester tester,
  ) async {
    bool didSignOut = false;

    await tester.pumpWidget(
      ProviderScope(
        // ignore: always_specify_types
        overrides: [
          authControllerProvider.overrideWith(
            () => _SignOutSpyAuthController(
              signedInUser,
              () => didSignOut = true,
            ),
          ),
          profileControllerProvider(
            signedInUser.uid,
          ).overrideWith(() => _FakeProfileController(hydratedProfile)),
          updateProfileUseCaseProvider.overrideWith(
            (Ref ref) => _StubUpdateProfileUseCase(),
          ),
          manageCategoryTreeProvider.overrideWith(
            (Ref ref) => Stream<List<CategoryTreeNode>>.value(
              const <CategoryTreeNode>[],
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out'));
    await tester.pump();

    expect(didSignOut, isTrue);
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  _RecordingNavigatorObserver(this.pushedRoutes);

  final List<Route<dynamic>> pushedRoutes;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}
