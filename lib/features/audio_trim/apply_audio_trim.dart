import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

import '../../models/audio_item.dart';
import '../../providers/audio_library_provider.dart';
import '../../providers/clear_audio_subtitles.dart';
import '../../providers/listening_practice/listening_practice_provider.dart';
import '../../services/app_logger.dart';
import '../../utils/app_data_dir.dart';
import 'audio_trim_service.dart';

/// 裁剪音频并同步库数据，返回更新后的 [AudioItem]。
///
/// 顺序：生成新文件 → 清除旧字幕（如有）→ 更新 DB → 删除波形缓存与旧文件。
/// 生成新文件失败直接抛出，此时原文件与 DB 均未改动。
Future<AudioItem> applyAudioTrim(
  WidgetRef ref,
  AudioItem audioItem, {
  required Duration start,
  required Duration end,
  AudioTrimService? service,
}) async {
  final oldPath = audioItem.audioPath!;
  final dataDir = await getAppDataDirectory();
  final result = await (service ?? AudioTrimService()).trim(
    dataDir: dataDir,
    relativePath: oldPath,
    start: start,
    end: end,
  );

  var base = audioItem;
  if (audioItem.hasTranscript) {
    base = await clearAudioSubtitles(ref, audioItem);
  }

  // originalAudioSha256 也换成新指纹：它是转录缓存键，沿用旧值会命中未裁剪版本的字幕；
  // 两者相等也让转录成功后照常把裁剪产物转码为 m4a。
  final updated = base.copyWith(
    audioPath: result.relativePath,
    audioSha256: result.sha256,
    originalAudioSha256: result.originalSha256,
    totalDuration: ((end - start).inMilliseconds / 1000).round(),
  );
  await ref.read(audioLibraryProvider.notifier).updateAudioItem(updated);

  final practiceState = ref.read(listeningPracticeProvider);
  if (practiceState.currentAudioItem?.id == audioItem.id) {
    ref
        .read(listeningPracticeProvider.notifier)
        .loadAudio(updated, forceTranscriptReload: true);
  }

  // 波形缓存按条目 id 命名，内容已变必须删除。
  await _deleteQuietly(
    File(p.join(dataDir.path, 'waveforms', '${audioItem.id}.wave')),
  );

  // 同内容导入会共享同一文件，仍被其他条目引用时不能删。
  if (result.relativePath != oldPath) {
    final stillReferenced = ref
        .read(audioLibraryProvider)
        .audioItems
        .any((it) => it.audioPath == oldPath);
    if (!stillReferenced) {
      await _deleteQuietly(File(p.join(dataDir.path, oldPath)));
    }
  }
  return updated;
}

Future<void> _deleteQuietly(File file) async {
  try {
    if (await file.exists()) await file.delete();
  } catch (e) {
    AppLogger.log('AudioTrim', 'delete failed(ignored) err=$e');
  }
}
