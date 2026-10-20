/// 自托管版全功能解锁的回归保护：
/// - 未登录也解锁全部 [PremiumFeature]；
/// - 订阅 controller 恒为 Premium，且任何刷新/恢复都不访问权益后端与缓存；
/// - 订阅入口 / Paywall / Web 结账一律隐藏（T2.3 方案 A）。
library;

import 'package:echo_loop/features/auth/providers/auth_providers.dart';
import 'package:echo_loop/features/subscription/models/premium_feature.dart';
import 'package:echo_loop/features/subscription/providers/feature_access_provider.dart';
import 'package:echo_loop/features/subscription/providers/subscription_availability.dart';
import 'package:echo_loop/features/subscription/providers/subscription_controller.dart';
import 'package:echo_loop/features/subscription/services/entitlement_cache.dart';
import 'package:echo_loop/features/subscription/services/entitlement_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// 默认（不 override 解锁开关）+ 未登录；权益后端与缓存一旦被读取即抛错。
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        isAuthenticatedProvider.overrideWithValue(false),
        entitlementRepositoryProvider.overrideWith(
          (ref) => throw StateError('自托管版不应访问权益后端'),
        ),
        entitlementCacheProvider.overrideWith(
          (ref) => throw StateError('自托管版不应读写权益缓存'),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('未登录也解锁全部 PremiumFeature', () {
    final container = createContainer();

    for (final feature in PremiumFeature.values) {
      expect(
        container.read(featureAccessProvider(feature)),
        isTrue,
        reason: '$feature 应解锁',
      );
    }
  });

  test('订阅 controller 恒为 Premium，刷新/恢复不访问后端', () async {
    final container = createContainer();
    final controller = container.read(subscriptionControllerProvider.notifier);

    expect(container.read(subscriptionControllerProvider).isActive, isTrue);

    await controller.refresh(force: true);
    await controller.refreshIfStale();
    await controller.restore();
    await controller.purchase('pro_yearly');
    await controller.clearLocalCacheAndRefresh();
    await controller.refreshAfterExternalCheckout();

    expect(container.read(subscriptionControllerProvider).isActive, isTrue);
  });

  test('Paddle 结账与订阅管理入口被禁用', () async {
    final container = createContainer();
    final controller = container.read(subscriptionControllerProvider.notifier);

    await expectLater(
      controller.startPaddleCheckout('pro_yearly'),
      throwsStateError,
    );
    await expectLater(controller.createPaddlePortal(), throwsStateError);
  });

  test('订阅入口、Web 结账与商店 Web 兜底一律隐藏', () {
    final container = createContainer();

    expect(container.read(subscriptionAvailabilityProvider), isFalse);
    expect(container.read(webCheckoutModeProvider), isFalse);
    expect(container.read(showStoreWebCheckoutFallbackProvider), isFalse);
  });
}
