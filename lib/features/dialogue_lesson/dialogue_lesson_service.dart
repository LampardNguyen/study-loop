/// 对话 → 语音课程：逐句调用 OpenAI TTS，拼接为一条音频，并按原文生成 SRT 字幕。
///
/// TTS 使用 `pcm`（24kHz / 单声道 / PCM16）格式，每句时长由字节数精确换算，
/// 字幕时间轴无需再做对齐；拼接后的 WAV 再转码为 m4a 入库。
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';
import 'package:uuid/uuid.dart';

import '../../models/audio_item.dart';
import '../../providers/audio_library_provider.dart';
import '../../providers/collection_provider.dart';
import '../../services/app_logger.dart';
import '../../services/openai/openai_audio_client.dart';
import '../../utils/app_data_dir.dart';
import '../ai_settings/models/ai_provider_config.dart';
import '../audio_import/audio_finalization_service.dart';
import '../audio_import/audio_import_cancel.dart';
import '../audio_import/audio_registration_service.dart';
import '../audio_import/audio_transcode_service.dart';
import 'dialogue_parser.dart';

/// OpenAI `pcm` 输出采样率。
const dialoguePcmSampleRate = 24000;

/// 句间静音时长。
const dialogueGap = Duration(milliseconds: 300);

/// 默认给说话人分配的声音（按出场顺序循环）。
const defaultDialogueVoices = ['ballad', 'sage', 'onyx', 'shimmer'];

/// 试听句数。
const dialoguePreviewLines = 2;

const _bytesPerMs = dialoguePcmSampleRate * 2 ~/ 1000;

/// 一句字幕的时间区间。
class DialogueCue {
  const DialogueCue({
    required this.text,
    required this.start,
    required this.end,
  });

  final String text;
  final Duration start;
  final Duration end;
}

/// 合成结果：WAV 文件 + SRT 文本。
class DialogueAudio {
  const DialogueAudio({required this.wavFile, required this.srt});

  final File wavFile;
  final String srt;
}

/// 对话课程生成失败原因。
enum DialogueLessonFailure { empty, encode, duplicate }

/// 对话课程生成失败。
class DialogueLessonException implements Exception {
  const DialogueLessonException(this.failure, this.message);

  final DialogueLessonFailure failure;
  final String message;

  @override
  String toString() => message;
}

/// 根据每句 PCM 字节数与 [gap] 计算字幕时间轴（句与句之间插入静音）。
List<DialogueCue> buildDialogueCues(
  List<DialogueLine> lines,
  List<int> pcmByteLengths, {
  Duration gap = dialogueGap,
}) {
  final cues = <DialogueCue>[];
  var cursor = Duration.zero;
  for (var i = 0; i < lines.length; i++) {
    if (i > 0) cursor += gap;
    final length = Duration(milliseconds: pcmByteLengths[i] ~/ _bytesPerMs);
    cues.add(
      DialogueCue(text: lines[i].text, start: cursor, end: cursor + length),
    );
    cursor += length;
  }
  return cues;
}

/// 生成 SRT 文本。
String dialogueCuesToSrt(List<DialogueCue> cues) {
  final buf = StringBuffer();
  for (var i = 0; i < cues.length; i++) {
    buf.writeln(i + 1);
    buf.writeln('${_srtTime(cues[i].start)} --> ${_srtTime(cues[i].end)}');
    buf.writeln(cues[i].text);
    buf.writeln();
  }
  return buf.toString();
}

String _srtTime(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
  return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:'
      '${two(d.inSeconds.remainder(60))},$ms';
}

/// 把 PCM16 单声道数据包成 WAV。
Uint8List pcm16ToWav(Uint8List pcm, {int sampleRate = dialoguePcmSampleRate}) {
  final header = ByteData(44);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      header.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little); // PCM
  header.setUint16(22, 1, Endian.little); // 单声道
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  return (BytesBuilder(copy: false)
        ..add(header.buffer.asUint8List())
        ..add(pcm))
      .takeBytes();
}

/// 对话课程生成服务。
class DialogueLessonService {
  static const _logTag = 'DialogueLesson';

  DialogueLessonService({
    OpenAiAudioClient? client,
    AudioTranscodeService? transcodeService,
    AudioRegistrationService? registrationService,
    Future<Directory> Function()? resolveDataDir,
    Uuid? uuid,
  }) : _client = client ?? OpenAiAudioClient(),
       _transcodeService = transcodeService ?? AudioTranscodeService(),
       _registrationService = registrationService ?? AudioRegistrationService(),
       _resolveDataDir = resolveDataDir ?? getAppDataDirectory,
       _uuid = uuid ?? const Uuid();

  final OpenAiAudioClient _client;
  final AudioTranscodeService _transcodeService;
  final AudioRegistrationService _registrationService;
  final Future<Directory> Function() _resolveDataDir;
  final Uuid _uuid;

  /// 逐句合成并拼接为 [outputWav]，返回 WAV 与 SRT。
  ///
  /// [voices] 为 说话人 → 声音；缺失时按出场顺序取 [defaultDialogueVoices]。
  Future<DialogueAudio> synthesizeToWav({
    required AiProviderConfig config,
    required List<DialogueLine> lines,
    required File outputWav,
    Map<String, String> voices = const {},
    String model = defaultSpeechModel,
    String? instructions,
    CancelToken? cancelToken,
    void Function(int done, int total)? onProgress,
  }) async {
    if (lines.isEmpty) {
      throw const DialogueLessonException(DialogueLessonFailure.empty, '对话为空');
    }
    final speakers = dialogueSpeakers(lines);
    String voiceOf(String speaker) =>
        voices[speaker] ??
        defaultDialogueVoices[speakers.indexOf(speaker) %
            defaultDialogueVoices.length];

    final gapBytes = Uint8List(dialogueGap.inMilliseconds * _bytesPerMs);
    final pcm = BytesBuilder(copy: false);
    final lengths = <int>[];
    onProgress?.call(0, lines.length);
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final bytes = await _synthesizeWithRetry(
        config,
        input: line.text,
        voice: voiceOf(line.speaker),
        model: model,
        instructions: instructions,
        cancelToken: cancelToken,
      );
      // PCM16 必须为偶数字节，防御性截掉末尾半个采样。
      final even = bytes.length - bytes.length % 2;
      if (i > 0) pcm.add(gapBytes);
      pcm.add(Uint8List.fromList(bytes.sublist(0, even)));
      lengths.add(even);
      onProgress?.call(i + 1, lines.length);
    }

    await outputWav.parent.create(recursive: true);
    await outputWav.writeAsBytes(pcm16ToWav(pcm.takeBytes()), flush: true);
    final srt = dialogueCuesToSrt(buildDialogueCues(lines, lengths));
    AppLogger.log(
      _logTag,
      'synthesized lines=${lines.length} speakers=${speakers.length}',
    );
    return DialogueAudio(wavFile: outputWav, srt: srt);
  }

  /// 试听：合成前 [dialoguePreviewLines] 句到 `tmp/dialogue_tts/preview.wav`（每次覆盖）。
  Future<File> preview({
    required AiProviderConfig config,
    required List<DialogueLine> lines,
    Map<String, String> voices = const {},
    String model = defaultSpeechModel,
    CancelToken? cancelToken,
  }) async {
    final dataDir = await _resolveDataDir();
    final audio = await synthesizeToWav(
      config: config,
      lines: lines.take(dialoguePreviewLines).toList(),
      outputWav: File(
        p.join(dataDir.path, 'tmp', 'dialogue_tts', 'preview.wav'),
      ),
      voices: voices,
      model: model,
      cancelToken: cancelToken,
    );
    return audio.wavFile;
  }

  /// 429 / 5xx / 网络错误重试一次；取消与其它错误直接抛出。
  Future<List<int>> _synthesizeWithRetry(
    AiProviderConfig config, {
    required String input,
    required String voice,
    required String model,
    String? instructions,
    CancelToken? cancelToken,
  }) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await _client.synthesizeSpeech(
          config,
          input: input,
          voice: voice,
          model: model,
          instructions: instructions,
          responseFormat: 'pcm',
          cancelToken: cancelToken,
        );
      } on DioException catch (e) {
        final status = e.response?.statusCode ?? 0;
        final retryable =
            e.type != DioExceptionType.cancel &&
            (status == 429 || status >= 500 || e.response == null);
        if (!retryable || attempt >= 1) rethrow;
        AppLogger.log(_logTag, 'retry speech status=$status');
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  /// 生成音频、入库为课程，并通过 [attachSubtitle] 挂载 SRT 字幕。
  Future<AudioItem> createLesson({
    required AiProviderConfig config,
    required String name,
    required List<DialogueLine> lines,
    required AudioLibrary audioLibrary,
    required AudioLibraryState audioLibraryState,
    required Future<void> Function(AudioItem item, String srt) attachSubtitle,
    Map<String, String> voices = const {},
    String model = defaultSpeechModel,
    String? instructions,
    CollectionList? collectionList,
    CollectionState? collectionState,
    String? collectionId,
    CancelToken? cancelToken,
    void Function(int done, int total)? onProgress,
  }) async {
    final dataDir = await _resolveDataDir();
    final tmpRelative = p.join('tmp', 'dialogue_tts', _uuid.v4());
    final tmpDir = Directory(p.join(dataDir.path, tmpRelative));
    try {
      final audio = await synthesizeToWav(
        config: config,
        lines: lines,
        outputWav: File(p.join(tmpDir.path, 'dialogue.wav')),
        voices: voices,
        model: model,
        instructions: instructions,
        cancelToken: cancelToken,
        onProgress: onProgress,
      );
      cancelToken?.throwIfCanceled();

      final m4a = File(p.join(tmpDir.path, 'dialogue.m4a'));
      final ok = await _transcodeService.transcodeToFile(
        source: audio.wavFile,
        output: m4a,
      );
      if (!ok) {
        throw const DialogueLessonException(
          DialogueLessonFailure.encode,
          '音频编码失败',
        );
      }

      final finalized =
          await AudioFinalizationService(
            transcodeService: _transcodeService,
            uuid: _uuid,
          ).finalize(
            dataDir: dataDir,
            tempRelativePath: p.join(tmpRelative, 'dialogue.m4a'),
            targetSubdir: 'audios',
            cancelToken: cancelToken,
          );

      final result = await _registrationService.registerSandboxedAudio(
        input: SandboxedAudioRegistrationInput(
          name: name,
          relativePath: finalized.relativePath,
          importSourceType: AudioImportSourceType.tts,
          audioSha256: finalized.sha256,
          originalAudioSha256: finalized.originalSha256,
        ),
        audioLibrary: audioLibrary,
        audioLibraryState: audioLibraryState,
        collectionList: collectionList,
        collectionState: collectionState,
        collectionId: collectionId,
        cancelToken: cancelToken,
      );
      switch (result) {
        case AudioRegistrationAdded(:final item):
          await attachSubtitle(item, audio.srt);
          return item;
        case AudioRegistrationDuplicate(:final existingName):
          throw DialogueLessonException(
            DialogueLessonFailure.duplicate,
            '已存在相同内容：$existingName',
          );
      }
    } finally {
      if (await tmpDir.exists()) {
        try {
          await tmpDir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }
}
