/// AI 配置持久化：只使用系统安全存储（Android Keystore / iOS Keychain）。
///
/// 不使用 SharedPreferences，避免 API Key 进入备份或被明文读取。
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../services/app_logger.dart';
import '../models/ai_provider_config.dart';

/// 安全存储中的键名。
const aiProviderConfigStorageKey = 'selfhost.ai_provider_config';

/// 安全存储读写失败。
class AiSettingsStorageException implements Exception {
  /// 构造异常。
  const AiSettingsStorageException(this.message, [this.cause]);

  /// 可读描述（不含 Key）。
  final String message;

  /// 底层异常。
  final Object? cause;

  @override
  String toString() => 'AiSettingsStorageException: $message';
}

/// AI 配置仓库。
class AiSettingsRepository {
  /// 构造仓库，[storage] 可注入以便测试。
  AiSettingsRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  /// 读取配置；未保存过返回默认配置（无 Key）。
  Future<AiProviderConfig> load() async {
    final String? raw;
    try {
      raw = await _storage.read(key: aiProviderConfigStorageKey);
    } catch (error) {
      throw AiSettingsStorageException('读取 AI 配置失败', error);
    }
    if (raw == null || raw.isEmpty) return const AiProviderConfig();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('AI 配置格式错误');
      }
      return AiProviderConfig.fromJson(decoded);
    } on FormatException catch (error) {
      // 损坏的配置不阻塞使用：记日志并回退默认，用户重新输入即可覆盖。
      AppLogger.log('AiSettings', 'config corrupted, fallback default: $error');
      return const AiProviderConfig();
    }
  }

  /// 保存完整配置。
  Future<void> save(AiProviderConfig config) async {
    try {
      await _storage.write(
        key: aiProviderConfigStorageKey,
        value: jsonEncode(config.toJson()),
      );
    } catch (error) {
      throw AiSettingsStorageException('保存 AI 配置失败', error);
    }
    AppLogger.log('AiSettings', 'saved ${config.logSummary}');
  }
}

/// AI 配置仓库 Provider。
final aiSettingsRepositoryProvider = Provider<AiSettingsRepository>(
  (ref) => AiSettingsRepository(),
);
