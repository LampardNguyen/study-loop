/// APK 直装更新的下载进度对话框。
///
/// 不可点外部关闭；显示进度条与「xx% · a/b MB」，可取消。
/// 下载完成后关闭并调起系统安装器。
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/apk_update_installer.dart';

/// 下载结果。
enum ApkDownloadResult { installed, cancelled, failed }

/// 显示下载对话框并执行「下载 → 安装」，返回结果。
Future<ApkDownloadResult> showApkDownloadDialog({
  required BuildContext context,
  required String url,
  required ApkUpdateInstaller installer,
}) async {
  final result = await showDialog<ApkDownloadResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: _ApkDownloadDialog(url: url, installer: installer),
    ),
  );
  return result ?? ApkDownloadResult.cancelled;
}

class _ApkDownloadDialog extends StatefulWidget {
  final String url;
  final ApkUpdateInstaller installer;

  const _ApkDownloadDialog({required this.url, required this.installer});

  @override
  State<_ApkDownloadDialog> createState() => _ApkDownloadDialogState();
}

class _ApkDownloadDialogState extends State<_ApkDownloadDialog> {
  final _cancelToken = CancelToken();
  int _received = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    ApkDownloadResult result;
    try {
      final apk = await widget.installer.download(
        widget.url,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _total = total;
          });
        },
      );
      await widget.installer.install(apk);
      result = ApkDownloadResult.installed;
    } catch (_) {
      result = _cancelToken.isCancelled
          ? ApkDownloadResult.cancelled
          : ApkDownloadResult.failed;
    }
    if (mounted) Navigator.of(context).pop(result);
  }

  String _mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = _total > 0 ? _received / _total : null;
    final detail = progress == null
        ? '${_mb(_received)} MB'
        : '${(progress * 100).floor()}%  ·  ${_mb(_received)}/${_mb(_total)} MB';

    return AlertDialog(
      title: Text(l10n.updateDownloading),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 12),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _cancelToken.cancel(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
