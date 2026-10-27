import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_io/io.dart';

import '../database/providers.dart';
import '../models/audio_item.dart';
import 'audio_library_provider.dart';
import 'audio_sentences_provider.dart';
import 'favorite_sentence_lifecycle_provider.dart';
import 'learning_progress_provider.dart';
import 'listening_practice/listening_practice_provider.dart';

/// 清除音频的字幕及依赖字幕的数据（收藏句子、学习进度、听力缓存）。
///
/// 供「删除字幕」与「裁剪音频」共用：裁剪后时间轴整体偏移，旧字幕必须一并清除。
/// 返回已清除字幕字段的 [AudioItem]，调用方可在其基础上继续更新。
Future<AudioItem> clearAudioSubtitles(
  WidgetRef ref,
  AudioItem audioItem,
) async {
  // 1. 删除本地字幕文件
  if (audioItem.transcriptPath != null) {
    try {
      final fullPath = await audioItem.getFullTranscriptPath();
      if (fullPath != null) {
        final file = File(fullPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {
      // 文件不存在不报错
    }
  }

  // 注意：不删除后端转录记录。
  // userAudios 表按 SHA256 去重，多个用户共享同一条记录，
  // 删除后端 transcript 会影响所有共用同一音频的用户。
  // 用户重新转录时，后端 upsert 会覆盖旧记录，无需手动删除。

  // 3. 清除字幕内容列与词级时间戳
  final audioDao = ref.read(audioItemDaoProvider);
  await audioDao.updateTranscriptSrt(audioItem.id, null);
  await audioDao.updateWordTimestamps(audioItem.id, null);
  // 字幕已变更（清空）→ 失效共享字幕投影，令其按新真相源（空）重解析。
  // autoDispose 通常已在离开本页时释放该 provider，此处为显式兜底保证同步。
  ref.invalidate(audioSentencesProvider(audioItem.id));

  // 4. 更新本地数据库：清除字幕相关字段
  final cleared = audioItem.copyWith(
    transcriptPath: null,
    transcriptSource: null,
    transcriptLanguage: null,
    sentenceCount: 0,
    wordCount: 0,
  );
  await ref.read(audioLibraryProvider.notifier).updateAudioItem(cleared);

  // 5. 删除该音频的所有收藏句子
  await ref
      .read(favoriteSentenceLifecycleProvider)
      .removeAllForAudio(audioItem.id);

  // 6. 重置该音频的学习进度
  // 学习进度基于句子索引/段落索引，字幕删除后这些索引失去参照；
  // 若不重置，重新导入字幕时旧断点会指向错位的句子。
  await ref
      .read(learningProgressNotifierProvider.notifier)
      .resetProgress(audioItem.id);

  // 7. 清除 listeningPracticeProvider 中缓存的句子数据
  // 字幕内容入库后 transcriptPath 恒为 null，loadAudio 去重守卫（比较 id +
  // transcriptPath）无法察觉变化，必须强制重载才能让 keepAlive 的 LP 丢弃旧句子。
  final practiceState = ref.read(listeningPracticeProvider);
  if (practiceState.currentAudioItem?.id == audioItem.id) {
    ref
        .read(listeningPracticeProvider.notifier)
        .loadAudio(cleared, forceTranscriptReload: true);
  }
  return cleared;
}
