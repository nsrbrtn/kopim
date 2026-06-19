import 'package:flutter_test/flutter_test.dart';
import 'package:kopim/features/app_shell/presentation/models/navigation_tab_config.dart';
import 'package:kopim/features/app_shell/presentation/providers/main_navigation_tabs_provider.dart';
import 'package:kopim/features/profile/presentation/controllers/feature_access_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

void main() {
  test('assistant tab is hidden when AI assistant is unavailable', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        featureAccessProvider.overrideWithValue(
          const FeatureAccess(
            entitlementState: EntitlementAccessState.freeLocal,
            cloudSync: FeatureGate(FeatureAccessStatus.requiresEntitlement),
            webApp: FeatureGate(FeatureAccessStatus.requiresEntitlement),
            aiAssistant: FeatureGate(FeatureAccessStatus.requiresEntitlement),
            advancedAnalytics: FeatureGate(
              FeatureAccessStatus.requiresEntitlement,
            ),
            isWebReadOnly: false,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final List<NavigationTabConfig> tabs = container.read(
      mainNavigationTabsProvider,
    );

    expect(
      tabs.any((NavigationTabConfig tab) => tab.id == 'assistant'),
      isFalse,
    );
  });

  test('assistant tab is shown when AI assistant is available', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        featureAccessProvider.overrideWithValue(
          const FeatureAccess(
            entitlementState: EntitlementAccessState.cloudActive,
            cloudSync: FeatureGate(FeatureAccessStatus.enabled),
            webApp: FeatureGate(FeatureAccessStatus.enabled),
            aiAssistant: FeatureGate(FeatureAccessStatus.enabled),
            advancedAnalytics: FeatureGate(FeatureAccessStatus.enabled),
            isWebReadOnly: false,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final List<NavigationTabConfig> tabs = container.read(
      mainNavigationTabsProvider,
    );

    expect(
      tabs.any((NavigationTabConfig tab) => tab.id == 'assistant'),
      isTrue,
    );
  });
}
