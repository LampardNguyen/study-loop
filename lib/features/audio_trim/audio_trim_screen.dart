import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

import '../../l10n/app_localizations.dart';
import '../../models/audio_item.dart';
import '../../services/app_logger.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_data_dir.dart';
import 'apply_audio_trim.dart';

/// 裁剪页试听播放器抽象（便于测试注入）。
abstract class TrimPreviewPlayer {
  /// 加载音频，返回时长（未知时 null）。
  Future<Duration?> load(String path);
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
  Future<void> seek(Duration position);

  /// 开始播放，不等待播放结束。
  void play();
  Future<void> pause();
  Future<void> dispose();
}

/// 基于 just_audio 的独立试听播放器，不影响全局播放引擎。
class JustAudioTrimPreviewPlayer implements TrimPreviewPlayer {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<Duration?> load(String path) => _player.setFilePath(path);
  @override
  Stream<Duration> get positionStream => _player.positionStream;
  @override
  Stream<bool> get playingStream => _player.playingStream;
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  void play() => unawaited(_player.play());
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> dispose() => _player.dispose();
}

typedef AudioTrimSaver =
    Future<AudioItem> Function(
      WidgetRef ref,
      AudioItem audioItem,
      Duration start,
      Duration end,
    );

/// 格式化裁剪时间：`mm:ss` 或 `mm:ss.s`，超过 1 小时为 `h:mm:ss`。
String formatTrimTime(Duration d, {bool tenths = false}) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final t = tenths ? '.${d.inMilliseconds.remainder(1000) ~/ 100}' : '';
  return h > 0 ? '$h:$m:$s$t' : '$m:$s$t';
}

/// 音频裁剪页：选起点/终点剪掉片头片尾广告，支持试听确认裁剪位置。
class AudioTrimScreen extends ConsumerStatefulWidget {
  const AudioTrimScreen({
    super.key,
    required this.audioItem,
    this.player,
    this.waveformLoader,
    this.saver,
  });

  final AudioItem audioItem;
  final TrimPreviewPlayer? player;
  final Future<Waveform?> Function(AudioItem item)? waveformLoader;
  final AudioTrimSaver? saver;

  @override
  ConsumerState<AudioTrimScreen> createState() => _AudioTrimScreenState();
}

enum _TrimHandle { start, end }

class _AudioTrimScreenState extends ConsumerState<AudioTrimScreen> {
  static const _minLength = Duration(seconds: 1);
  static const _step = Duration(seconds: 1);
  static const _previewLength = Duration(seconds: 5);
  static const _dragPreviewLength = Duration(seconds: 3);

  late final TrimPreviewPlayer _player =
      widget.player ?? JustAudioTrimPreviewPlayer();
  final List<StreamSubscription<Object?>> _subs = [];

  Duration _duration = Duration.zero;
  Duration _start = Duration.zero;
  Duration _end = Duration.zero;
  Duration _position = Duration.zero;
  bool _playing = false;

  /// 试听区间终点：播放到此处自动暂停（null 表示不限制）。
  Duration? _stopAt;
  bool _loaded = false;
  Waveform? _waveform;
  bool _waveformFailed = false;
  bool _saving = false;

  bool get _dirty => _start > Duration.zero || _end < _duration;

  @override
  void initState() {
    super.initState();
    _subs.add(_player.positionStream.listen(_onPosition));
    _subs.add(
      _player.playingStream.listen((v) {
        if (mounted) setState(() => _playing = v);
      }),
    );
    unawaited(_load());
  }

  Future<void> _load() async {
    Duration? duration;
    try {
      final path = await widget.audioItem.getFullAudioPath();
      if (path != null) duration = await _player.load(path);
    } catch (e) {
      AppLogger.log('AudioTrim', 'load player failed err=$e');
    }
    duration ??= Duration(seconds: widget.audioItem.totalDuration);
    if (!mounted) return;
    setState(() {
      _duration = duration!;
      _end = duration;
      _loaded = true;
    });

    final waveform = await (widget.waveformLoader ?? _loadWaveform)(
      widget.audioItem,
    );
    if (!mounted) return;
    setState(() {
      _waveform = waveform;
      _waveformFailed = waveform == null;
    });
  }

  /// 读取或提取波形；与字幕编辑器共用 `waveforms/<id>.wave` 缓存与缩放。
  static Future<Waveform?> _loadWaveform(AudioItem item) async {
    try {
      final audioPath = await item.getFullAudioPath();
      if (audioPath == null) return null;
      final dataDir = await getAppDataDirectory();
      final waveFile = File(
        p.join(dataDir.path, 'waveforms', '${item.id}.wave'),
      );
      if (await waveFile.exists()) return JustWaveform.parse(waveFile);
      await waveFile.parent.create(recursive: true);
      Waveform? waveform;
      await for (final progress in JustWaveform.extract(
        audioInFile: File(audioPath),
        waveOutFile: waveFile,
        zoom: const WaveformZoom.pixelsPerSecond(80),
      ).timeout(const Duration(seconds: 60))) {
        waveform = progress.waveform ?? waveform;
      }
      return waveform;
    } catch (e) {
      AppLogger.log('AudioTrim', 'waveform failed err=$e');
      return null;
    }
  }

  void _onPosition(Duration pos) {
    if (!mounted) return;
    final stopAt = _stopAt;
    if (stopAt != null && pos >= stopAt) {
      _stopAt = null;
      unawaited(_player.pause());
      pos = stopAt;
    }
    setState(() => _position = pos);
  }

  Future<void> _playRange(Duration from, Duration until) async {
    _stopAt = until;
    await _player.seek(from);
    setState(() => _position = from);
    _player.play();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.pause();
    } else {
      _stopAt = null;
      _player.play();
    }
  }

  Future<void> _seek(Duration to) async {
    await _player.seek(to);
    if (mounted) setState(() => _position = to);
  }

  Duration _clampStart(Duration v) {
    final max = _end - _minLength;
    if (v < Duration.zero) return Duration.zero;
    return v > max ? max : v;
  }

  Duration _clampEnd(Duration v) {
    final min = _start + _minLength;
    if (v > _duration) return _duration;
    return v < min ? min : v;
  }

  void _setStart(Duration v) => setState(() => _start = _clampStart(v));
  void _setEnd(Duration v) => setState(() => _end = _clampEnd(v));

  Duration _min(Duration a, Duration b) => a < b ? a : b;
  Duration _max(Duration a, Duration b) => a > b ? a : b;

  void _playFromStart() =>
      _playRange(_start, _min(_start + _previewLength, _end));
  void _playToEnd() => _playRange(_max(_end - _previewLength, _start), _end);
  void _playResult() => _playRange(_start, _end);

  void _onHandleReleased(_TrimHandle handle) {
    if (handle == _TrimHandle.start) {
      _playRange(_start, _min(_start + _dragPreviewLength, _end));
    } else {
      _playRange(_max(_end - _dragPreviewLength, _start), _end);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await _player.pause();
    setState(() => _saving = true);
    try {
      final saver =
          widget.saver ??
          (ref, item, start, end) =>
              applyAudioTrim(ref, item, start: start, end: end);
      await saver(ref, widget.audioItem, _start, _end);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.audioTrimDone(formatTrimTime(_end - _start))),
        ),
      );
      navigator.pop(true);
    } catch (e) {
      AppLogger.log('AudioTrim', 'save failed err=$e');
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.audioTrimFailed)));
    }
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.audioTrimDiscardTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop(false);
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canSave = _loaded && _dirty && !_saving;

    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _saving) return;
        unawaited(_confirmDiscard());
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(l10n.audioTrimTitle),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s),
                  child: FilledButton(
                    onPressed: canSave ? _save : null,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
            body: !_loaded
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(l10n, theme),
          ),
          if (_saving)
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.surface.withValues(alpha: 0.75),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.m),
                      Material(
                        type: MaterialType.transparency,
                        child: Text(l10n.audioTrimSaving),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme) {
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final totalMs = _duration.inMilliseconds;
    final removed = _start + (_duration - _end);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        Text(
          widget.audioItem.name,
          style: theme.textTheme.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.m),
        // 两侧留白：把手远离屏幕边缘，避免拖动时触发系统返回手势。
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: _TrimWaveform(
            waveform: _waveform,
            loading: _waveform == null && !_waveformFailed,
            duration: _duration,
            start: _start,
            end: _end,
            position: _position,
            onSeek: _seek,
            onHandleMoved: (h, t) =>
                h == _TrimHandle.start ? _setStart(t) : _setEnd(t),
            onHandleReleased: _onHandleReleased,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00', style: muted),
              Text(formatTrimTime(_duration), style: muted),
            ],
          ),
        ),
        if (_waveformFailed)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(l10n.audioTrimWaveformFailed, style: muted),
          ),
        Row(
          children: [
            IconButton(
              key: const ValueKey('audioTrimPlayPause'),
              onPressed: _togglePlay,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            ),
            Expanded(
              child: Slider(
                value: _position.inMilliseconds.clamp(0, totalMs).toDouble(),
                max: totalMs > 0 ? totalMs.toDouble() : 1,
                onChanged: (v) => _seek(Duration(milliseconds: v.round())),
              ),
            ),
            Text(
              '${formatTrimTime(_position)} / ${formatTrimTime(_duration)}',
              style: muted,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PointCard(
                key: const ValueKey('audioTrimStartCard'),
                label: l10n.audioTrimStart,
                time: _start,
                onMinus: () => _setStart(_start - _step),
                onPlus: () => _setStart(_start + _step),
                onSetHere: () => _setStart(_position),
                setHereLabel: l10n.audioTrimSetHere,
                onPreview: _playFromStart,
                previewLabel: l10n.audioTrimPlayFromStart,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: _PointCard(
                key: const ValueKey('audioTrimEndCard'),
                label: l10n.audioTrimEnd,
                time: _end,
                onMinus: () => _setEnd(_end - _step),
                onPlus: () => _setEnd(_end + _step),
                onSetHere: () => _setEnd(_position),
                setHereLabel: l10n.audioTrimSetHere,
                onPreview: _playToEnd,
                previewLabel: l10n.audioTrimPlayToEnd,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: l10n.audioTrimNewLength(formatTrimTime(_end - _start)),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (_dirty)
                TextSpan(
                  text: '  ${l10n.audioTrimRemoved(formatTrimTime(removed))}',
                  style: muted,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        OutlinedButton.icon(
          onPressed: _playResult,
          icon: const Icon(Icons.play_circle_outline),
          label: Text(l10n.audioTrimPlayResult),
        ),
      ],
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({
    super.key,
    required this.label,
    required this.time,
    required this.onMinus,
    required this.onPlus,
    required this.onSetHere,
    required this.setHereLabel,
    required this.onPreview,
    required this.previewLabel,
  });

  final String label;
  final Duration time;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onSetHere;
  final String setHereLabel;
  final VoidCallback onPreview;
  final String previewLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            formatTrimTime(time, tenths: true),
            style: theme.textTheme.titleLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: compact,
                  onPressed: onMinus,
                  child: const Text('−1s'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: OutlinedButton(
                  style: compact,
                  onPressed: onPlus,
                  child: const Text('+1s'),
                ),
              ),
            ],
          ),
          TextButton.icon(
            style: compact,
            onPressed: onSetHere,
            icon: const Icon(Icons.vertical_align_bottom, size: 18),
            label: Text(setHereLabel, overflow: TextOverflow.ellipsis),
          ),
          TextButton.icon(
            style: compact,
            onPressed: onPreview,
            icon: const Icon(Icons.play_arrow, size: 18),
            label: Text(previewLabel, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// 整段波形 + 起止把手 + 播放头。拖把手调整起止，点按/拖动空白处定位播放。
class _TrimWaveform extends StatefulWidget {
  const _TrimWaveform({
    required this.waveform,
    required this.loading,
    required this.duration,
    required this.start,
    required this.end,
    required this.position,
    required this.onSeek,
    required this.onHandleMoved,
    required this.onHandleReleased,
  });

  final Waveform? waveform;
  final bool loading;
  final Duration duration;
  final Duration start;
  final Duration end;
  final Duration position;
  final ValueChanged<Duration> onSeek;
  final void Function(_TrimHandle handle, Duration time) onHandleMoved;
  final ValueChanged<_TrimHandle> onHandleReleased;

  @override
  State<_TrimWaveform> createState() => _TrimWaveformState();
}

class _TrimWaveformState extends State<_TrimWaveform> {
  static const double _height = 140;
  static const double _handleHitRadius = 28;
  _TrimHandle? _dragging;

  Duration _timeAt(double x, double width) {
    if (width <= 0) return Duration.zero;
    final frac = (x / width).clamp(0.0, 1.0);
    return Duration(
      milliseconds: (widget.duration.inMilliseconds * frac).round(),
    );
  }

  double _xOf(Duration t, double width) {
    final ms = widget.duration.inMilliseconds;
    return ms <= 0 ? 0 : t.inMilliseconds / ms * width;
  }

  _TrimHandle? _hitHandle(double x, double width) {
    final ds = (x - _xOf(widget.start, width)).abs();
    final de = (x - _xOf(widget.end, width)).abs();
    if (ds > _handleHitRadius && de > _handleHitRadius) return null;
    return ds <= de ? _TrimHandle.start : _TrimHandle.end;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          key: const ValueKey('audioTrimWaveform'),
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => widget.onSeek(_timeAt(d.localPosition.dx, width)),
          onHorizontalDragStart: (d) =>
              _dragging = _hitHandle(d.localPosition.dx, width),
          onHorizontalDragUpdate: (d) {
            final t = _timeAt(d.localPosition.dx, width);
            final h = _dragging;
            if (h == null) {
              widget.onSeek(t);
            } else {
              widget.onHandleMoved(h, t);
            }
          },
          onHorizontalDragEnd: (_) {
            final h = _dragging;
            _dragging = null;
            if (h != null) widget.onHandleReleased(h);
          },
          child: SizedBox(
            height: _height,
            width: width,
            child: CustomPaint(
              painter: _TrimWaveformPainter(
                waveform: widget.waveform,
                loading: widget.loading,
                startX: _xOf(widget.start, width),
                endX: _xOf(widget.end, width),
                playheadX: _xOf(widget.position, width),
                waveColor: scheme.primary,
                backgroundColor: scheme.surfaceContainerHighest,
                shadeColor: scheme.onSurface.withValues(alpha: 0.22),
                handleColor: const Color(0xFFFF9500),
                playheadColor: scheme.error,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrimWaveformPainter extends CustomPainter {
  _TrimWaveformPainter({
    required this.waveform,
    required this.loading,
    required this.startX,
    required this.endX,
    required this.playheadX,
    required this.waveColor,
    required this.backgroundColor,
    required this.shadeColor,
    required this.handleColor,
    required this.playheadColor,
  });

  static const double _knobHeight = 20;

  final Waveform? waveform;
  final bool loading;
  final double startX;
  final double endX;
  final double playheadX;
  final Color waveColor;
  final Color backgroundColor;
  final Color shadeColor;
  final Color handleColor;
  final Color playheadColor;

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = size.height - _knobHeight;
    final waveRect = Rect.fromLTWH(0, 0, size.width, waveHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(waveRect, const Radius.circular(10)),
      Paint()..color = backgroundColor,
    );

    final centerY = waveHeight / 2;
    final wf = waveform;
    if (wf != null && wf.length > 0) {
      final maxValue = wf.flags == 0 ? 32768.0 : 128.0;
      final paint = Paint()
        ..color = waveColor
        ..strokeWidth = 1.5;
      for (double x = 0; x < size.width; x += 2.5) {
        final idx = (x / size.width * wf.length).floor().clamp(
          0,
          wf.length - 1,
        );
        final minY = centerY + wf.getPixelMin(idx) / maxValue * waveHeight / 2;
        final maxY = centerY + wf.getPixelMax(idx) / maxValue * waveHeight / 2;
        canvas.drawLine(Offset(x, minY), Offset(x, maxY), paint);
      }
    } else if (!loading) {
      // 无波形：画一条中线作为时间轴。
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        Paint()
          ..color = waveColor
          ..strokeWidth = 2,
      );
    }

    // 裁掉的区域置灰
    final shade = Paint()..color = shadeColor;
    canvas.drawRect(Rect.fromLTRB(0, 0, startX, waveHeight), shade);
    canvas.drawRect(Rect.fromLTRB(endX, 0, size.width, waveHeight), shade);

    // 播放头
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, waveHeight),
      Paint()
        ..color = playheadColor
        ..strokeWidth = 2,
    );

    _drawHandle(canvas, startX, waveHeight, 'S');
    _drawHandle(canvas, endX, waveHeight, 'E');
  }

  void _drawHandle(Canvas canvas, double x, double waveHeight, String label) {
    final paint = Paint()
      ..color = handleColor
      ..strokeWidth = 3;
    canvas.drawLine(Offset(x, 0), Offset(x, waveHeight), paint);
    final knob = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, waveHeight + _knobHeight / 2),
        width: 22,
        height: _knobHeight,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(knob, Paint()..color = handleColor);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, knob.center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_TrimWaveformPainter old) =>
      old.waveform != waveform ||
      old.loading != loading ||
      old.startX != startX ||
      old.endX != endX ||
      old.playheadX != playheadX ||
      old.waveColor != waveColor;
}
