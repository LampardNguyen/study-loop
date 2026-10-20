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

  /// 转写 [audioFile]，返回 `verbose_json` 原始结果（含 segments 与词级时间戳）。
  ///
  /// [language] 为 ISO-639-1 代码；传 null 让模型自动识别。
  Future<Map<String, dynamic>> transcribeVerbose(
    AiProviderConfig config,
    File audioFile, {
    String? language,
    String model = defaultTranscriptionModel,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final url = '${normalizeAiBaseUrl(config.baseUrl)}/audio/transcriptions';
    AppLogger.log(
      'OpenAI',
      'transcribe verbose start ${config.logSummary} model=$model '
          'language=${language ?? 'auto'} bytes=${await audioFile.length()}',
    );
    final response = await _dio.post<Object?>(
      url,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.uri.pathSegments.last,
        ),
        'model': model,
        'language': ?language,
        'response_format': 'verbose_json',
        // multiCompatible 会编码为 timestamp_granularities[]=word&...=segment。
        'timestamp_granularities': ['word', 'segment'],
      }, ListFormat.multiCompatible),
      options: Options(
        validateStatus: (_) => true,
        headers: {'Authorization': 'Bearer ${config.apiKey}'},
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status != 200 || data is! Map<String, dynamic>) {
      AppLogger.log('OpenAI', 'transcribe verbose failed status=$status');
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    final segments = data['segments'];
    final words = data['words'];
    AppLogger.log(
      'OpenAI',
      'transcribe verbose done '
          'segments=${segments is List ? segments.length : 0} '
          'words=${words is List ? words.length : 0}',
    );
    return data;
  }

  /// 释放资源。
  void dispose() => _dio.close();
}
