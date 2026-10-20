/// OpenAI 兼容接口的语音转写客户端（`POST {baseUrl}/audio/transcriptions`）。
///
/// 自托管版用于复述评估：先把学习者录音转成文本，再交给 Chat 模型评估。
/// 错误约定与 [OpenAiChatClient] 一致：非 200 抛带状态码的 [DioException]。
library;

import 'package:dio/dio.dart';
import 'package:universal_io/io.dart';

import '../../features/ai_settings/models/ai_provider_config.dart';
import '../app_logger.dart';

/// 默认转写模型。
const defaultTranscriptionModel = 'whisper-1';

/// 语音转写客户端。
class OpenAiAudioClient {
  /// 构造客户端；[dio] 可注入以便测试。
  OpenAiAudioClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(minutes: 2),
              receiveTimeout: const Duration(minutes: 3),
            ),
          );

  final Dio _dio;

  /// 转写 [audioFile]，返回纯文本。
  Future<String> transcribe(
    AiProviderConfig config,
    File audioFile, {
    String language = 'en',
    String model = defaultTranscriptionModel,
    CancelToken? cancelToken,
  }) async {
    final url = '${normalizeAiBaseUrl(config.baseUrl)}/audio/transcriptions';
    AppLogger.log(
      'OpenAI',
      'transcribe start ${config.logSummary} model=$model '
          'bytes=${await audioFile.length()}',
    );
    final response = await _dio.post<Object?>(
      url,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.uri.pathSegments.last,
        ),
        'model': model,
        'language': language,
        'response_format': 'json',
      }),
      options: Options(
        validateStatus: (_) => true,
        headers: {'Authorization': 'Bearer ${config.apiKey}'},
      ),
      cancelToken: cancelToken,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status != 200) {
      AppLogger.log('OpenAI', 'transcribe failed status=$status');
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    final text = data is Map ? data['text'] : null;
    final result = text is String ? text.trim() : '';
    AppLogger.log('OpenAI', 'transcribe done chars=${result.length}');
    return result;
  }

  /// 释放资源。
  void dispose() => _dio.close();
}
