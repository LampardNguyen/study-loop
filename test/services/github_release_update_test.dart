/// 自托管版 GitHub Releases 更新源测试。
library;

import 'package:dio/dio.dart';
import 'package:echo_loop/models/app_update_info.dart';
import 'package:echo_loop/services/android_update_bridge.dart';
import 'package:echo_loop/services/app_update_checker.dart';
import 'package:echo_loop/services/github_release_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class _FakeBridge implements AndroidUpdateBridge {
  @override
  Future<String?> installerPackageName() async => null;

  @override
  Future<bool> canInstallPackages() async => true;

  @override
  Future<void> openInstallPermissionSettings() async {}

  @override
  Future<void> installApk(String path) async {}
}

const _releaseUrl =
    'https://api.github.com/repos/LampardNguyen/study-loop/releases/latest';

Map<String, dynamic> _release({
  String tag = 'v1.0.43',
  List<Map<String, dynamic>> assets = const [
    {
      'name': 'study-loop-1.0.43.apk',
      'browser_download_url': 'https://github.com/x/y/releases/download/a.apk',
    },
  ],
}) => {
  'tag_name': tag,
  'html_url': 'https://github.com/LampardNguyen/study-loop/releases/tag/$tag',
  'body': '  Thêm tính năng mới  ',
  'assets': assets,
};

void main() {
  group('parseGithubLatestRelease', () {
    test('解析 tag、更新说明与 APK 附件直链', () {
      final info = parseGithubLatestRelease(_release())!;

      expect(info.latestVersion, '1.0.43');
      expect(info.minimumVersion, '0.0.0');
      expect(info.releaseNotes, {'en': 'Thêm tính năng mới'});
      expect(
        info.downloadUrl['androidApk'],
        'https://github.com/x/y/releases/download/a.apk',
      );
      expect(info.channel, AppUpdateChannel.androidApk);
    });

    test('没有 APK 附件时回退到 Release 页面', () {
      final info = parseGithubLatestRelease(
        _release(
          assets: const [
            {'name': 'notes.txt', 'browser_download_url': 'https://x/notes'},
          ],
        ),
      )!;

      expect(
        info.downloadUrl['androidApk'],
        'https://github.com/LampardNguyen/study-loop/releases/tag/v1.0.43',
      );
    });

    test('tag 不是语义化版本时视为无更新', () {
      expect(parseGithubLatestRelease(_release(tag: 'latest')), isNull);
      expect(parseGithubLatestRelease({'body': 'x'}), isNull);
    });
  });

  group('AppUpdateChecker (GitHub 源)', () {
    late MockDio dio;

    setUp(() {
      dio = MockDio();
      registerFallbackValue(Options());
    });

    AppUpdateChecker checker() => AppUpdateChecker.withDio(
      dio,
      platform: AppUpdateRuntimePlatform.android,
      androidBridge: _FakeBridge(),
      githubReleaseUrl: _releaseUrl,
    );

    test('Android 自托管版请求 GitHub 最新 Release 而非 version.json', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(), data: _release()),
      );

      final info = await checker().check();

      expect(info?.latestVersion, '1.0.43');
      verify(
        () => dio.get<Map<String, dynamic>>(
          _releaseUrl,
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('请求失败（如尚无 Release 的 404）静默返回 null', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(await checker().check(), isNull);
    });
  });
}
