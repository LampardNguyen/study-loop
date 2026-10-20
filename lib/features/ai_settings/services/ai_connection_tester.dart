/// 「测试连接」：用 `GET {baseUrl}/models` 验证 Key 与地址是否可用。
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/app_logger.dart';
import '../models/ai_provider_config.dart';

/// 连接测试结果。
sealed class AiConnectionResult {
  const AiConnectionResult();
}

/// 连接成功；[modelCount] 为接口返回的模型数量（未知为 null）。
class AiConnectionOk extends AiConnectionResult {
  /// 构造成功结果。
  const AiConnectionOk(this.modelCount);

  /// 可用模型数量。
  final int? modelCount;
}

/// Key 无效或无权限（401 / 403）。
class AiConnectionUnauthorized extends AiConnectionResult {
  /// 构造鉴权失败结果。
  const AiConnectionUnauthorized(this.statusCode);

  /// HTTP 状态码。
  final int statusCode;
}

/// 服务端返回其他错误状态码。
class AiConnectionHttpError extends AiConnectionResult {
  /// 构造 HTTP 错误结果。
  const AiConnectionHttpError(this.statusCode);

  /// HTTP 状态码。
  final int statusCode;
}

/// 网络不可达 / 超时 / 证书错误等。
class AiConnectionNetworkError extends AiConnectionResult {
  /// 构造网络错误结果。
  const AiConnectionNetworkError(this.message);

  /// 简短错误描述（不含 Key）。
  final String message;
}

/// 连接测试器。
class AiConnectionTester {
  /// 构造测试器，[dio] 可注入以便测试。
  AiConnectionTester({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// 测试超时。
  static const timeout = Duration(seconds: 15);

  /// 用 [config] 发起一次 `GET /models`。
  Future<AiConnectionResult> test(AiProviderConfig config) async {
    final url = '${normalizeAiBaseUrl(config.baseUrl)}/models';
    AppLogger.log('AiSettings', 'test connection ${config.logSummary}');
    try {
      final response = await _dio.get<Object?>(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer ${config.apiKey}'},
          sendTimeout: timeout,
          receiveTimeout: timeout,
          responseType: ResponseType.json,
        ),
      );
      final data = response.data;
      final models = data is Map ? data['data'] : null;
      final result = AiConnectionOk(models is List ? models.length : null);
      AppLogger.log('AiSettings', 'test ok models=${result.modelCount}');
      return result;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      AppLogger.log(
        'AiSettings',
        'test failed status=$status type=${error.type.name}',
      );
      if (status != null) {
        return status == 401 || status == 403
            ? AiConnectionUnauthorized(status)
            : AiConnectionHttpError(status);
      }
      // 只展示主机名与错误类型，避免把冗长的底层异常文本直接抛给用户。
      final host = Uri.tryParse(url)?.host ?? url;
      return AiConnectionNetworkError('$host (${error.type.name})');
    }
  }
}

/// 连接测试器 Provider。
final aiConnectionTesterProvider = Provider<AiConnectionTester>(
  (ref) => AiConnectionTester(),
);
