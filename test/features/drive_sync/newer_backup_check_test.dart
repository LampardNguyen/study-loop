import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:echo_loop/features/drive_sync/drive_sync_marker.dart';
import 'package:echo_loop/features/drive_sync/drive_sync_service.dart';
import 'package:echo_loop/features/drive_sync/newer_backup_check.dart';
import 'package:echo_loop/l10n/app_localizations.dart';

DriveMediaIndex _index({String? deviceId = 'B', DateTime? at}) =>
    DriveMediaIndex(
      dbSha256: 'x',
      createdAt: at ?? DateTime.utc(2026, 10, 31, 14, 30),
      appVersion: '1.0.0',
      files: const {},
      deviceId: deviceId,
      deviceName: deviceId == null ? null : 'Galaxy S21',
    );

void main() {
  group('shouldOfferNewerBackup', () {
    const none = DriveSyncMarker();
    final t = DateTime.utc(2026, 10, 31, 14, 30);

    test('其它设备的新备份且本机未同步过 → 提示', () {
      expect(
        shouldOfferNewerBackup(remote: _index(), myDeviceId: 'A', marker: none),
        isTrue,
      );
    });

    test('无备份 / 本机备份 / 旧版本备份 → 不提示', () {
      expect(
        shouldOfferNewerBackup(remote: null, myDeviceId: 'A', marker: none),
        isFalse,
      );
      expect(
        shouldOfferNewerBackup(remote: _index(), myDeviceId: 'B', marker: none),
        isFalse,
      );
      expect(
        shouldOfferNewerBackup(
          remote: _index(deviceId: null),
          myDeviceId: 'A',
          marker: none,
        ),
        isFalse,
      );
    });

    test('不晚于上次同步 → 不提示；更晚 → 提示', () {
      expect(
        shouldOfferNewerBackup(
          remote: _index(at: t),
          myDeviceId: 'A',
          marker: DriveSyncMarker(lastSyncedAt: t),
        ),
        isFalse,
      );
      expect(
        shouldOfferNewerBackup(
          remote: _index(at: t.add(const Duration(minutes: 1))),
          myDeviceId: 'A',
          marker: DriveSyncMarker(lastSyncedAt: t),
        ),
        isTrue,
      );
    });

    test('点过以后再说的同一份备份 → 不再提示，有更新的才提示', () {
      expect(
        shouldOfferNewerBackup(
          remote: _index(at: t),
          myDeviceId: 'A',
          marker: DriveSyncMarker(dismissedAt: t),
        ),
        isFalse,
      );
      expect(
        shouldOfferNewerBackup(
          remote: _index(at: t.add(const Duration(hours: 1))),
          myDeviceId: 'A',
          marker: DriveSyncMarker(dismissedAt: t),
        ),
        isTrue,
      );
    });
  });

  test('hasLocalChanges：从未同步或数据库变化', () {
    final t = DateTime.utc(2026);
    expect(hasLocalChanges(const DriveSyncMarker(), 'a'), isTrue);
    expect(
      hasLocalChanges(DriveSyncMarker(lastSyncedAt: t, dbSha256: 'a'), 'a'),
      isFalse,
    );
    expect(
      hasLocalChanges(DriveSyncMarker(lastSyncedAt: t, dbSha256: 'a'), 'b'),
      isTrue,
    );
  });

  test('索引 JSON 保留设备信息，旧索引无设备字段', () {
    final json = _index().toJson();
    final back = DriveMediaIndex.fromJson(json);
    expect(back.deviceId, 'B');
    expect(back.deviceName, 'Galaxy S21');
    final old = DriveMediaIndex.fromJson(
      Map.of(json)
        ..remove('deviceId')
        ..remove('deviceName'),
    );
    expect(old.deviceId, isNull);
  });

  group('showNewerBackupDialog', () {
    Future<bool?> open(
      WidgetTester tester, {
      required bool localChanges,
      DateTime? lastSyncedAt,
    }) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showNewerBackupDialog(
                context,
                deviceName: 'Galaxy S21',
                createdAt: DateTime(2026, 10, 31, 21, 30),
                localChanges: localChanges,
                lastSyncedAt: lastSyncedAt,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('无本地改动：显示设备与时间，点恢复返回 true', (tester) async {
      await open(tester, localChanges: false);
      expect(find.text('Có bản sao lưu mới hơn'), findsOneWidget);
      expect(find.textContaining('Galaxy S21 lúc 21:30, 31/10'), findsOneWidget);
      expect(find.textContaining('thay toàn bộ dữ liệu'), findsOneWidget);
      expect(find.text('Vẫn khôi phục'), findsNothing);
    });

    testWidgets('有本地改动：警告 + 仍然恢复', (tester) async {
      await open(
        tester,
        localChanges: true,
        lastSyncedAt: DateTime(2026, 10, 31, 20, 5),
      );
      expect(find.textContaining('chưa sao lưu từ 20:05, 31/10'), findsOneWidget);
      expect(find.text('Vẫn khôi phục'), findsOneWidget);
    });

    testWidgets('从未同步：提示数据未备份', (tester) async {
      await open(tester, localChanges: true);
      expect(find.textContaining('chưa từng sao lưu'), findsOneWidget);
    });
  });
}
