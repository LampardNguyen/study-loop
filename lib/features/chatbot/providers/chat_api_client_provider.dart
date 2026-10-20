/// ChatApi 单例 provider。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../ai_settings/providers/ai_settings_provider.dart';
import '../chatbot_flags.dart';
import '../services/chat_api_client.dart';
import '../services/fake_chat_api_client.dart';
import '../services/openai_chat_api.dart';

part 'chat_api_client_provider.g.dart';

/// ChatApi 单例（keepAlive）。
///
/// kChatbotUseFakeApi=true（仅 debug 联调用）时返回假实现；否则构造 OpenAI 直连客户端。
@Riverpod(keepAlive: true)
ChatApi chatApiClient(Ref ref) {
  if (kChatbotUseFakeApi) return const FakeChatApiClient();
  // 自托管版：直连用户自有 OpenAI 兼容接口（Key 来自「AI 设置」）。
  final client = OpenAiChatApi(
    readConfig: () => ref.read(aiSettingsProvider.future),
  );
  ref.onDispose(client.dispose);
  return client;
}
