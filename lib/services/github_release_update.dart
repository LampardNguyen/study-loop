/// 自托管版更新源：GitHub Releases。
///
/// 原作者的 version.json 后端在自托管版不可用，Android APK 渠道改为读取本 fork
/// 的 `releases/latest`：tag（如 `v1.0.43`）即最新版本，正文即更新说明，
/// 附件中的 `.apk` 即下载链接。
library;

import '../models/app_update_info.dart';

/// 把 GitHub `releases/latest` 响应解析为 [AppUpdateInfo]。
///
/// tag 缺失或不是 `vX.Y.Z` / `X.Y.Z` 形式时返回 null（无法比较版本，视为无更新）。
/// 找不到 `.apk` 附件时回退到 Release 页面链接，由用户在浏览器中下载。
AppUpdateInfo? parseGithubLatestRelease(Map<String, dynamic> json) {
  final tag = json['tag_name'];
  if (tag is! String) return null;
  final version = tag.startsWith('v') ? tag.substring(1) : tag;
  if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) return null;

  final apkUrl = _firstApkAssetUrl(json['assets']);
  final pageUrl = json['html_url'];
  final downloadUrl = apkUrl ?? (pageUrl is String ? pageUrl : null);

  final body = json['body'];
  final notes = body is String ? body.trim() : '';

  return AppUpdateInfo(
    latestVersion: version,
    // GitHub Release 不表达「最低兼容版本」，自托管版不做强制更新。
    minimumVersion: '0.0.0',
    // 更新说明只写一种语言，作为 en 兜底（弹窗按 locale → en 取值）。
    releaseNotes: notes.isEmpty ? const {} : {'en': notes},
    downloadUrl: {
      if (downloadUrl != null) 'android': downloadUrl,
      if (downloadUrl != null) 'androidApk': downloadUrl,
    },
    channel: AppUpdateChannel.androidApk,
  );
}

/// 取第一个 `.apk` 附件的下载直链。
String? _firstApkAssetUrl(Object? assets) {
  if (assets is! List) return null;
  for (final asset in assets) {
    if (asset is! Map) continue;
    final name = asset['name'];
    final url = asset['browser_download_url'];
    if (name is String &&
        name.toLowerCase().endsWith('.apk') &&
        url is String) {
      return url;
    }
  }
  return null;
}
