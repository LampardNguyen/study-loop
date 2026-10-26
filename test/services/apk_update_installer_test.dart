import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:echo_loop/l10n/app_localizations.dart';
import 'package:echo_loop/models/app_update_info.dart';
import 'package:echo_loop/services/android_update_bridge.dart';
import 'package:echo_loop/services/apk_update_installer.dart';
import 'package:echo_loop/services/app_update_launcher.dart';

/// 返回固定字节（或抛错）的假 HTTP 适配器。
class _FakeAdapter implements HttpClientAdapter {
  final List<int> bytes;
  final bool fail;

  _FakeAdapter(this.bytes, {this.fail = false});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (fail) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody(
      Stream.fromIterable([
        Uint8List.fromList(bytes.sublist(0, bytes.length ~/ 2)),
        Uint8List.fromList(bytes.sublist(bytes.length ~/ 2)),
      ]),
      200,
      headers: {
        Headers.contentLengthHeader: ['${bytes.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeBridge implements AndroidUpdateBridge {
  bool canInstall = true;
  final List<String> installed = [];

  @override
  Future<String?> installerPackageName() async => null;

  @override
  Future<bool> canInstallPackages() async => canInstall;

  @override
  Future<void> openInstallPermissionSettings() async {}

  @override
  Future<void> installApk(String path) async => installed.add(path);
}

class _FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final List<String> launched = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}

void main() {
  late Directory tmp;
  late _FakeBridge bridge;
  final apkBytes = List<int>.generate(1000, (i) => i % 256);

  ApkUpdateInstaller makeInstaller({bool fail = false}) => ApkUpdateInstaller(
    dio: Dio()..httpClientAdapter = _FakeAdapter(apkBytes, fail: fail),
    bridge: bridge,
    cacheDir: () async => tmp,
  );

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('apk_update_test');
    bridge = _FakeBridge();
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  group('ApkUpdateInstaller', () {
    test('下载到缓存 updates/ 目录、上报进度并清理旧文件', () async {
      final old = File('${tmp.path}/updates/old.apk')
        ..createSync(recursive: true);
      final progress = <int>[];

      final apk = await makeInstaller().download(
        'https://example.com/a.apk',
        onProgress: (received, total) {
          expect(total, apkBytes.length);
          progress.add(received);
        },
      );

      expect(apk.path, '${tmp.path}/updates/update.apk');
      expect(apk.readAsBytesSync(), apkBytes);
      expect(progress.last, apkBytes.length);
      expect(old.existsSync(), isFalse);
    });

    test('install 把 APK 路径交给原生桥接', () async {
      final apk = File('${tmp.path}/x.apk')..createSync();
      await makeInstaller().install(apk);
      expect(bridge.installed, [apk.path]);
    });

    test('下载失败抛出 DioException', () async {
      expect(
        makeInstaller(fail: true).download('https://example.com/a.apk'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('AppUpdateLauncher 应用内安装', () {
    late _FakeUrlLauncher urlLauncher;
    const apkInfo = AppUpdateInfo(
      latestVersion: '2.0.0',
      minimumVersion: '0.0.0',
      channel: AppUpdateChannel.androidApk,
    );
    const url = 'https://example.com/a.apk';

    setUp(() {
      urlLauncher = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = urlLauncher;
    });

    Future<void> runLaunch(
      WidgetTester tester,
      ApkUpdateInstaller installer,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final future = AppUpdateLauncher(
          installer: installer,
          forceAndroid: true,
        ).launch(info: apkInfo, primaryUrl: url, context: ctx);
        // 让下载对话框的异步流程跑完。
        for (var i = 0; i < 20; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
        await future;
      });
    }

    testWidgets('下载成功：调起安装器，不打开浏览器', (tester) async {
      await runLaunch(tester, makeInstaller());
      expect(bridge.installed, hasLength(1));
      expect(urlLauncher.launched, isEmpty);
    });

    testWidgets('下载失败：回退到浏览器打开 APK 链接', (tester) async {
      await runLaunch(tester, makeInstaller(fail: true));
      expect(bridge.installed, isEmpty);
      expect(urlLauncher.launched, [url]);
    });
  });
}
