/// 自托管版 AI 提供方配置（OpenAI 兼容接口）。
///
/// API Key 由用户在 App 内自行输入，只存放在系统安全存储中，
/// 绝不在构建期注入、也不写日志（日志只用 [logSummary]）。
library;

/// 默认 OpenAI 兼容接口地址。
const defaultAiBaseUrl = 'https://api.openai.com/v1';

/// 默认对话模型。
const defaultAiModel = 'gpt-4.1-mini';

/// Base URL 校验失败原因。
enum AiBaseUrlError {
  /// 为空或无法解析。
  invalid,

  /// 非 https，且不是本机 / 局域网地址。
  insecure,
}

/// OpenAI 兼容接口配置。
class AiProviderConfig {
  /// 构造配置；[apiKey] 为空串表示未配置。
  const AiProviderConfig({
    this.apiKey = '',
    this.baseUrl = defaultAiBaseUrl,
    this.model = defaultAiModel,
  });

  /// 用户的 API Key（空串 = 未配置）。
  final String apiKey;

  /// 接口根地址，不含末尾 `/`，如 `https://api.openai.com/v1`。
  final String baseUrl;

  /// 对话模型名。
  final String model;

  /// 是否已配置 API Key。
  bool get hasApiKey => apiKey.isNotEmpty;

  /// 已配置时的脱敏展示，如 `sk-••••4f2a`；未配置返回空串。
  String get maskedApiKey {
    if (!hasApiKey) return '';
    final tail = apiKey.length <= 4
        ? apiKey
        : apiKey.substring(apiKey.length - 4);
    final prefix = apiKey.startsWith('sk-') ? 'sk-' : '';
    return '$prefix••••$tail';
  }

  /// 可安全写入日志的摘要（不含 Key）。
  String get logSummary {
    final host = Uri.tryParse(baseUrl)?.host ?? '?';
    return 'hasKey=$hasApiKey baseUrlHost=$host model=$model';
  }

  /// 返回替换部分字段后的新配置。
  AiProviderConfig copyWith({String? apiKey, String? baseUrl, String? model}) {
    return AiProviderConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
    );
  }

  /// 序列化为 JSON（仅供安全存储使用）。
  Map<String, String> toJson() => {
    'apiKey': apiKey,
    'baseUrl': baseUrl,
    'model': model,
  };

  /// 从 JSON 反序列化；缺失字段回退默认值。
  factory AiProviderConfig.fromJson(Map<String, Object?> json) {
    String read(String key, String fallback) {
      final value = json[key];
      return value is String && value.trim().isNotEmpty
          ? value.trim()
          : fallback;
    }

    return AiProviderConfig(
      apiKey: read('apiKey', ''),
      baseUrl: normalizeAiBaseUrl(read('baseUrl', defaultAiBaseUrl)),
      model: read('model', defaultAiModel),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AiProviderConfig &&
      other.apiKey == apiKey &&
      other.baseUrl == baseUrl &&
      other.model == model;

  @override
  int get hashCode => Object.hash(apiKey, baseUrl, model);
}

/// 去掉首尾空白与末尾 `/`。
String normalizeAiBaseUrl(String raw) {
  var value = raw.trim();
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}

/// 校验 Base URL；合法返回 null。
///
/// 只允许 https；http 仅放行本机与局域网地址（本地模型服务器场景）。
AiBaseUrlError? validateAiBaseUrl(String raw) {
  final uri = Uri.tryParse(normalizeAiBaseUrl(raw));
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return AiBaseUrlError.invalid;
  }
  if (uri.scheme == 'https') return null;
  if (uri.scheme == 'http' && _isLocalHost(uri.host)) return null;
  if (uri.scheme == 'http') return AiBaseUrlError.insecure;
  return AiBaseUrlError.invalid;
}

/// 是否为本机或私有网段地址。
bool _isLocalHost(String host) {
  if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
    return true;
  }
  if (host.endsWith('.local')) return true;
  final parts = host.split('.').map(int.tryParse).toList();
  if (parts.length != 4 || parts.any((p) => p == null)) return false;
  final a = parts[0]!;
  final b = parts[1]!;
  return a == 10 || (a == 192 && b == 168) || (a == 172 && b >= 16 && b <= 31);
}
