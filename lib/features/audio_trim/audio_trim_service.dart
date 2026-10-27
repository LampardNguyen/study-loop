import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';
import 'package:uuid/uuid.dart';

import '../../services/app_logger.dart';
import '../audio_import/audio_finalization_service.dart';
import '../audio_import/audio_import_models.dart';
import '../audio_import/audio_transcode_service.dart';

/// 音频裁剪（剪掉片头/片尾广告）的文件层服务。
///
/// 只负责「截取 → 按指纹落盘」：输出新的正式音频文件，**不删除原文件、不改 DB**，
/// 由调用方在 DB 更新成功后再清理旧文件（与转录后转码的顺序一致）。
class AudioTrimService {
  AudioTrimService({
    AudioTranscodeService? transcodeService,
    AudioFinalizationService? finalizationService,
    Uuid? uuid,
  }) : _transcodeService = transcodeService ?? AudioTranscodeService(),
       _finalizationService = finalizationService ?? AudioFinalizationService(),
       _uuid = uuid ?? const Uuid();

  final AudioTranscodeService _transcodeService;
  final AudioFinalizationService _finalizationService;
  final Uuid _uuid;

  /// 截取 [relativePath]（相对 [dataDir]）的 [start, end) 区间，落盘到原文件同目录。
  ///
  /// 先流复制，失败再回退 AAC 重编码为 m4a；两者都失败抛 [AudioImportException]。
  Future<FinalizedAudio> trim({
    required Directory dataDir,
    required String relativePath,
    required Duration start,
    required Duration end,
  }) async {
    final source = File(p.join(dataDir.path, relativePath));
    const tmpSubdir = 'tmp/audio_import';
    await Directory(p.join(dataDir.path, tmpSubdir)).create(recursive: true);

    final copyName = '${_uuid.v4()}${p.extension(relativePath)}';
    var tmpName = copyName;
    var ok = await _transcodeService.trimToFile(
      source: source,
      output: File(p.join(dataDir.path, tmpSubdir, copyName)),
      start: start,
      end: end,
    );
    if (!ok) {
      AppLogger.log('AudioTrim', 'stream copy failed, fallback to reencode');
      tmpName = '${_uuid.v4()}.m4a';
      ok = await _transcodeService.trimToFile(
        source: source,
        output: File(p.join(dataDir.path, tmpSubdir, tmpName)),
        start: start,
        end: end,
        reencode: true,
      );
    }
    if (!ok) {
      throw const AudioImportException(
        AudioImportFailureCode.storage,
        'Failed to trim audio',
      );
    }

    return _finalizationService.finalize(
      dataDir: dataDir,
      tempRelativePath: p.join(tmpSubdir, tmpName),
      targetSubdir: p.dirname(relativePath),
    );
  }
}
