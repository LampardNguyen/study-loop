/// APK 直装更新：应用内下载 APK 并调起系统安装器。
///
/// 下载到缓存目录 `updates/`（与原生 FileProvider 的 `update_file_paths.xml`
/// 对应），每次下载前清空旧文件；安装与「安装未知应用」授权走
/// [AndroidUpdateBridge]。
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'android_update_bridge.dart';

/// 下载进度回调：[received] 已下载字节，[total] 总字节（未知时 <= 0）。
typedef ApkDownloadProgress = void Function(int received, int total);

class ApkUpdateInstaller {
  final Dio _dio;
  final AndroidUpdateBridge _bridge;
  final Future<Directory> Function() _cacheDir;

  ApkUpdateInstaller({
    Dio? dio,
    AndroidUpdateBridge bridge = const MethodChannelAndroidUpdateBridge(),
    Future<Directory> Function()? cacheDir,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 60),
             ),
           ),
       _bridge = bridge,
       _cacheDir = cacheDir ?? getTemporaryDirectory;

  Future<bool> canInstall() => _bridge.canInstallPackages();

  Future<void> openInstallPermissionSettings() =>
      _bridge.openInstallPermissionSettings();

  /// 下载 [url] 到缓存目录，返回 APK 文件。取消或失败时抛出 [DioException]。
  Future<File> download(
    String url, {
    ApkDownloadProgress? onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = Directory('${(await _cacheDir()).path}/updates');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);

    final file = File('${dir.path}/update.apk');
    await _dio.download(
      url,
      file.path,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
    return file;
  }

  Future<void> install(File apk) => _bridge.installApk(apk.path);
}
