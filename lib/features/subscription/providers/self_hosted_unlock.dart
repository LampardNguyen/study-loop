/// 自托管版「全功能解锁」总开关。
///
/// 自托管版不接入任何订阅/支付后端：开启时所有 [PremiumFeature] 直接解锁、
/// 无需登录，订阅 controller 恒为 Premium 且不发起任何权益网络请求。
///
/// 默认 `true`。保留为 provider（而非 const）是为了让原有订阅逻辑的单测
/// 可以 override 为 `false`，继续验证原始的付费墙行为。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/entitlement.dart';
import '../state/entitlement_state.dart';

/// 是否启用自托管全功能解锁。
final selfHostedUnlockAllProvider = Provider<bool>((ref) => true);

/// 自托管版恒定的 Premium 权益状态（永久有效、无到期时间）。
const selfHostedPremiumState = EntitlementState(
  status: EntitlementStatus.premium,
  entitlement: Entitlement(isPremium: true),
);
