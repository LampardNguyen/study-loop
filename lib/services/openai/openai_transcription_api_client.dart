/// 自托管版 AI 转录：保持 [TranscriptionApiClient] 的公开签名，但不再走
/// 原作者后端（R2 上传 + 服务端任务），而是把本地音频直接交给用户自己的
/// OpenAI 兼容接口（`audio/transcriptions`，`verbose_json` + 词级时间戳）。
///
/// 与原流程的映射（`transcription_task_provider` 无需改动）：
/// 1. [getUploadUrl] 返回伪上传地址 `selfhost://<sha>`；
/// 2. [uploadToR2] 不上传，只记住 sha → 本地文件路径；
/// 3. [submitTranscription] 同步调用 Whisper，结果以 `cached=true` 直接返回，
///    因此不会进入轮询分支（[getJobStatus] / [getTranscript] 不会被调用）。
library;

import 'package:dio/dio.dart';
import 'package:universal_io/io.dart';

import '../../models/word_timestamp.dart';
import '../../utils/srt_generator.dart';
import '../app_logger.dart';
import '../transcription_api_client.dart';
import 'openai_audio_client.dart';
import 'openai_sentence_ai_api_client.dart' show AiConfigReader;

/// 伪上传地址前缀。
const _selfHostUploadScheme = 'selfhost://';

/// 基于 OpenAI 兼容接口的 [TranscriptionApiClient] 实现。
class OpenAiTranscriptionApiClient extends TranscriptionApiClient {
  /// 构造；[audio] 可注入以便测试。
  OpenAiTranscriptionApiClient({
    required AiConfigReader readConfig,
    OpenAiAudioClient? audio,
  }) : _readConfig = readConfig,
       _audio = audio ?? OpenAiAudioClient(),
       super.withDio(Dio());

  final AiConfigReader _readConfig;
  final OpenAiAudioClient _audio;

  /// sha256 → 待转录的本地文件路径（由 [uploadToR2] 记录）。
  final Map<String, String> _pendingFiles = {};

  @override
  Future<UploadUrlResponse> getUploadUrl({
    required String sha256,
    required String mimeType,
    required int fileSize,
    required String accessToken,
  }) async => UploadUrlResponse(
    audioExists: false,
    uploadUrl: '$_selfHostUploadScheme$sha256',
  );

  @override
  Future<void> uploadToR2({
    required String uploadUrl,
    required String filePath,
    required String contentType,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (!uploadUrl.startsWith(_selfHostUploadScheme)) {
      throw StateError('自托管版不支持上传到外部地址');
    }
    _pendingFiles[uploadUrl.substring(_selfHostUploadScheme.length)] = filePath;
  }

  @override
  Future<SubmitTranscriptionResponse> submitTranscription({
    required String sha256,
    String? fileName,
    String? objectName,
    String? publicUrl,
    String? mimeType,
    int? fileSize,
    required String language,
    required String accessToken,
    bool mergeSentences = true,
  }) async {
    final path = _pendingFiles.remove(sha256);
    if (path == null) {
      throw StateError('找不到待转录的本地音频（sha=$sha256）');
    }
    final config = await _readConfig();
    if (!config.hasApiKey) {
      final request = RequestOptions(path: '/audio/transcriptions');
      throw DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 401),
        type: DioExceptionType.badResponse,
      );
    }
    final raw = await _audio.transcribeVerbose(
      config,
      File(path),
      language: _whisperLanguage(language),
    );
    final transcript = transcriptFromWhisperVerbose(raw);
    AppLogger.log(
      'Transcription',
      'whisper done sentences=${transcript.sentences.length} '
          'words=${transcript.words?.length ?? 0}',
    );
    return SubmitTranscriptionResponse(cached: true, transcript: transcript);
  }

  @override
  Future<JobStatusResponse> getJobStatus(
    String jobId, {
    required String accessToken,
  }) async => const JobStatusResponse(
    status: 'failed',
    errorMessage: '自托管版转录为同步调用，没有服务端任务',
  );

  @override
  Future<TranscriptResult> getTranscript(
    String sha256,
    String language, {
    required String accessToken,
    bool mergeSentences = true,
  }) async {
    throw StateError('自托管版没有服务端字幕缓存');
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  /// App 的语言码（如 `en`、`en-US`、`auto`）→ Whisper 的 ISO-639-1；未知交给自动识别。
  static String? _whisperLanguage(String language) {
    final code = language.split(RegExp('[-_]')).first.toLowerCase();
    return RegExp(r'^[a-z]{2}$').hasMatch(code) ? code : null;
  }
}

/// 把 Whisper `verbose_json` 转为 [TranscriptResult]（纯函数，便于测试）。
///
/// - 词：取 `words[]`（无标点）；
/// - 句：以带标点的 `segments[]` 为基础，段内再按 `. ! ?` 切句，并按词数
///   顺序把段内的词分配给各句以得到精确起止时间与词下标；词数对不上时
///   退化为「整段一句」，时间取段的起止。
TranscriptResult transcriptFromWhisperVerbose(Map<String, dynamic> raw) {
  final words = <WordTimestamp>[
    for (final w in _list(raw['words']))
      if (w is Map && w['word'] is String)
        WordTimestamp(
          word: (w['word'] as String).trim(),
          startTime: _seconds(w['start']),
          endTime: _seconds(w['end']),
        ),
  ];
  final sentences = <TranscriptSentence>[];
  var wordCursor = 0;
  for (final seg in _list(raw['segments'])) {
    if (seg is! Map || seg['text'] is! String) continue;
    final text = (seg['text'] as String).trim();
    if (text.isEmpty) continue;
    final segStart = _seconds(seg['start']);
    final segEnd = _seconds(seg['end']);
    // 段内的词：起点落在段时间范围内（容差 50ms）。
    final segWordStart = wordCursor;
    while (wordCursor < words.length &&
        words[wordCursor].startTime <
            segEnd + const Duration(milliseconds: 50)) {
      wordCursor++;
    }
    final segWords = words.sublist(segWordStart, wordCursor);
    sentences.addAll(
      _splitSegment(text, segStart, segEnd, segWords, segWordStart),
    );
  }
  if (sentences.isEmpty && raw['text'] is String) {
    final text = (raw['text'] as String).trim();
    if (text.isNotEmpty) {
      sentences.add(
        TranscriptSentence(
          text: text,
          startTime: Duration.zero,
          endTime: _seconds(raw['duration']),
        ),
      );
    }
  }
  return TranscriptResult(
    sentences: sentences,
    words: words.isEmpty ? null : words,
    fullText: raw['text'] is String ? (raw['text'] as String).trim() : '',
  );
}

List<TranscriptSentence> _splitSegment(
  String text,
  Duration segStart,
  Duration segEnd,
  List<WordTimestamp> segWords,
  int firstWordIndex,
) {
  final pieces = text
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  final counts = [for (final p in pieces) p.split(RegExp(r'\s+')).length];
  final total = counts.fold<int>(0, (a, b) => a + b);
  if (segWords.isEmpty || total != segWords.length) {
    return [
      TranscriptSentence(
        text: text,
        startTime: segStart,
        endTime: segEnd,
        startWordIndex: segWords.isEmpty ? null : firstWordIndex,
        endWordIndex: segWords.isEmpty
            ? null
            : firstWordIndex + segWords.length - 1,
      ),
    ];
  }
  final out = <TranscriptSentence>[];
  var offset = 0;
  for (var i = 0; i < pieces.length; i++) {
    final first = segWords[offset];
    final last = segWords[offset + counts[i] - 1];
    out.add(
      TranscriptSentence(
        text: pieces[i],
        startTime: first.startTime,
        endTime: last.endTime,
        startWordIndex: firstWordIndex + offset,
        endWordIndex: firstWordIndex + offset + counts[i] - 1,
      ),
    );
    offset += counts[i];
  }
  return out;
}

List<Object?> _list(Object? value) => value is List ? value : const [];

Duration _seconds(Object? value) => value is num
    ? Duration(milliseconds: (value * 1000).round())
    : Duration.zero;
